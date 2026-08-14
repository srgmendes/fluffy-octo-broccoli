"""Interpretability tool: extract and verify per-layer "refusal directions".

Reproduces the PROBE -> DISTILL -> VERIFY steps from refusal-direction
interpretability research (see Arditi et al., "Refusal in Language Models
Is Mediated by a Single Direction", 2024) for a chat model of your choice:

  PROBE   Run paired harmful/harmless instructions through the model and
          record each layer's residual-stream activation at the last
          prompt token.
  DISTILL Compute a candidate refusal direction per layer two ways:
          diff-of-means, and the top right-singular-vector of the
          per-example difference matrix (SVD).
          harmful_i - mean(harmless) via SVD.
  VERIFY  Project held-out activations onto each candidate direction and
          report a separation score (Cohen's d) per layer, plus a plot,
          so you can see which layer/direction actually separates the
          two prompt classes.

Scope: this script only reads activations. It never edits model weights,
performs directional ablation, or saves a modified model — if you need
that, it is out of scope for this repo (see README.md in this directory).

Usage:
    python extract_refusal_directions.py \
        --model Qwen/Qwen2.5-0.5B-Instruct \
        --harmful-file prompts/harmful.txt \
        --harmless-file prompts/harmless.txt \
        --output-dir outputs

Requires network egress to the model host (e.g. huggingface.co) to
download weights, and the dependencies in requirements.txt installed.
"""

import argparse
import pathlib

import numpy as np
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer


def load_prompts(path: pathlib.Path) -> list[str]:
    lines = path.read_text(encoding="utf-8").splitlines()
    return [line.strip() for line in lines if line.strip()]


def collect_last_token_activations(
    model, tokenizer, prompts: list[str], device: str
) -> np.ndarray:
    """Returns array of shape (num_prompts, num_layers, hidden_size)."""
    per_prompt_layers = []
    for prompt in prompts:
        chat = [{"role": "user", "content": prompt}]
        input_ids = tokenizer.apply_chat_template(
            chat, add_generation_prompt=True, return_tensors="pt"
        ).to(device)
        with torch.no_grad():
            out = model(input_ids, output_hidden_states=True)
        # hidden_states: tuple(num_layers + 1) of (1, seq_len, hidden)
        # skip the embedding layer (index 0); keep one vector per decoder layer.
        last_token = [h[0, -1, :].float().cpu().numpy() for h in out.hidden_states[1:]]
        per_prompt_layers.append(np.stack(last_token))
    return np.stack(per_prompt_layers)


def diff_of_means_direction(harmful: np.ndarray, harmless: np.ndarray) -> np.ndarray:
    """harmful, harmless: (num_prompts, num_layers, hidden) -> (num_layers, hidden)."""
    return harmful.mean(axis=0) - harmless.mean(axis=0)


def svd_direction(harmful: np.ndarray, harmless: np.ndarray) -> np.ndarray:
    """Top right-singular-vector of the per-example diff matrix, per layer."""
    num_layers = harmful.shape[1]
    directions = []
    for layer in range(num_layers):
        diffs = harmful[:, layer, :] - harmless[:, layer, :].mean(axis=0, keepdims=True)
        _, _, vt = np.linalg.svd(diffs, full_matrices=False)
        directions.append(vt[0])
    return np.stack(directions)


def cohens_d(a: np.ndarray, b: np.ndarray) -> float:
    pooled_std = np.sqrt((a.var(ddof=1) + b.var(ddof=1)) / 2)
    if pooled_std == 0:
        return 0.0
    return float((a.mean() - b.mean()) / pooled_std)


def separation_scores(
    harmful: np.ndarray, harmless: np.ndarray, directions: np.ndarray
) -> np.ndarray:
    """Cohen's d between projected harmful/harmless activations, per layer."""
    num_layers = directions.shape[0]
    scores = np.zeros(num_layers)
    for layer in range(num_layers):
        direction = directions[layer] / (np.linalg.norm(directions[layer]) + 1e-8)
        proj_harmful = harmful[:, layer, :] @ direction
        proj_harmless = harmless[:, layer, :] @ direction
        scores[layer] = cohens_d(proj_harmful, proj_harmless)
    return scores


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--model",
        default="Qwen/Qwen2.5-0.5B-Instruct",
        help="HuggingFace model id or local path of a chat/instruct model.",
    )
    parser.add_argument("--harmful-file", default="prompts/harmful.txt")
    parser.add_argument("--harmless-file", default="prompts/harmless.txt")
    parser.add_argument("--output-dir", default="outputs")
    parser.add_argument(
        "--device", default="cuda" if torch.cuda.is_available() else "cpu"
    )
    args = parser.parse_args()

    output_dir = pathlib.Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"Loading {args.model} on {args.device} ...")
    tokenizer = AutoTokenizer.from_pretrained(args.model)
    model = AutoModelForCausalLM.from_pretrained(args.model, torch_dtype="auto")
    model.to(args.device)
    model.eval()

    harmful_prompts = load_prompts(pathlib.Path(args.harmful_file))
    harmless_prompts = load_prompts(pathlib.Path(args.harmless_file))
    if len(harmful_prompts) != len(harmless_prompts):
        raise ValueError(
            "harmful/harmless prompt files must be paired 1:1 "
            f"(got {len(harmful_prompts)} vs {len(harmless_prompts)})"
        )

    print(f"PROBE: collecting activations for {len(harmful_prompts)} paired prompts ...")
    harmful_acts = collect_last_token_activations(model, tokenizer, harmful_prompts, args.device)
    harmless_acts = collect_last_token_activations(model, tokenizer, harmless_prompts, args.device)

    print("DISTILL: computing candidate directions per layer ...")
    dom_directions = diff_of_means_direction(harmful_acts, harmless_acts)
    svd_directions = svd_direction(harmful_acts, harmless_acts)

    cos_sim = np.array(
        [
            np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b) + 1e-8)
            for a, b in zip(dom_directions, svd_directions)
        ]
    )

    print("VERIFY: scoring separation per layer (Cohen's d, diff-of-means direction) ...")
    dom_scores = separation_scores(harmful_acts, harmless_acts, dom_directions)
    best_layer = int(np.argmax(np.abs(dom_scores)))

    np.save(output_dir / "diff_of_means_directions.npy", dom_directions)
    np.save(output_dir / "svd_directions.npy", svd_directions)
    np.save(output_dir / "cohens_d_per_layer.npy", dom_scores)

    print("\nPer-layer separation (Cohen's d) and diff-of-means/SVD agreement (cosine sim):")
    for layer, (score, sim) in enumerate(zip(dom_scores, cos_sim)):
        marker = "  <-- strongest" if layer == best_layer else ""
        print(f"  layer {layer:3d}: d={score:+.3f}  cos_sim={sim:+.3f}{marker}")

    try:
        import matplotlib.pyplot as plt

        fig, axes = plt.subplots(1, 2, figsize=(11, 4))
        axes[0].plot(dom_scores)
        axes[0].axvline(best_layer, color="red", linestyle="--", alpha=0.5)
        axes[0].set_title("Separation (Cohen's d) by layer")
        axes[0].set_xlabel("layer")
        axes[0].set_ylabel("Cohen's d")

        direction = dom_directions[best_layer]
        direction = direction / (np.linalg.norm(direction) + 1e-8)
        proj_harmful = harmful_acts[:, best_layer, :] @ direction
        proj_harmless = harmless_acts[:, best_layer, :] @ direction
        axes[1].hist(proj_harmless, bins=12, alpha=0.6, label="harmless")
        axes[1].hist(proj_harmful, bins=12, alpha=0.6, label="harmful")
        axes[1].set_title(f"Projection onto layer {best_layer} direction")
        axes[1].legend()

        fig.tight_layout()
        fig.savefig(output_dir / "refusal_direction_analysis.png", dpi=150)
        print(f"\nSaved plot to {output_dir / 'refusal_direction_analysis.png'}")
    except ImportError:
        print("\n(matplotlib not installed; skipping plot)")

    print(f"Saved direction arrays to {output_dir}/")


if __name__ == "__main__":
    main()
