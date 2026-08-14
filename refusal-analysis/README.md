# Refusal-direction analysis

A small, self-contained script for interpretability research into how chat
models represent "refusal" internally. It reproduces the analysis-only
steps of refusal-direction research such as Arditi et al., *"Refusal in
Language Models Is Mediated by a Single Direction"* (2024):

1. **PROBE** — run paired harmful/harmless instructions through a model and
   record each layer's residual-stream activation at the last prompt token.
2. **DISTILL** — compute a candidate refusal direction per layer via
   diff-of-means and via SVD of the per-example difference matrix.
3. **VERIFY** — project activations onto each candidate direction and report
   a per-layer separation score (Cohen's d), plus a plot, so you can see
   which layer's direction actually distinguishes the two prompt classes.

## Out of scope

This tool **only reads activations** — it does not edit model weights,
perform directional ablation, or save a modified/"de-refused" model. If you
need that, it's a different project with different risk considerations and
isn't set up here.

## Setup

```bash
cd refusal-analysis
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
```

## Running

```bash
python extract_refusal_directions.py \
    --model Qwen/Qwen2.5-0.5B-Instruct \
    --harmful-file prompts/harmful.txt \
    --harmless-file prompts/harmless.txt \
    --output-dir outputs
```

- `--model` accepts any HuggingFace chat/instruct model id or local path.
  The default is small enough to run on CPU; swap in a larger model (e.g. a
  Llama or Qwen chat model) for a stronger, more literature-comparable
  signal, at the cost of more memory/compute.
- `prompts/harmful.txt` and `prompts/harmless.txt` are paired line-by-line —
  each harmful instruction has a matching benign counterpart on the same
  line number, covering the same surface topic (e.g. "pick a door lock
  without a key" vs. "pick a fresh watermelon"). Swap in your own paired
  prompt sets for a different domain, keeping the pairing intact.
- Outputs (direction vectors as `.npy`, per-layer Cohen's d scores, and a
  plot) are written to `--output-dir` (git-ignored — these are runtime
  artifacts, not something to commit).

## Sandbox caveat

Downloading model weights needs network egress to the model host (e.g.
`huggingface.co`) and `pypi.org` for dependencies — allow those domains in
the sandbox egress policy first. Model weights can be several hundred MB to
several GB depending on which model you pick.
