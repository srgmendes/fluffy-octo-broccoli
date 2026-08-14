# vLLM

Setup docs for [vLLM](https://github.com/vllm-project/vllm.git) — a
high-throughput inference and serving engine for large language models. This
directory has no application code of its own; it just documents how to
install and run the `vllm` command locally.

## Requirements

- Linux (vLLM does not officially support macOS/Windows natively; use WSL2 or
  Docker on those platforms)
- Python 3.9–3.12
- An NVIDIA GPU with CUDA 12.1+ for the default (GPU) build. CPU-only and
  other-accelerator builds are available — see below.
- [`pipx`](https://pipx.pypa.io/) (recommended) or `pip3`

## Install (GPU)

```bash
cd vllm
./install.sh          # pipx install vllm (falls back to pip3 install --user)
```

This pulls in PyTorch and CUDA runtime libraries as dependencies, so expect a
multi-gigabyte download and several minutes of install time.

Verify:

```bash
vllm --version
```

## Install (CPU-only)

If there's no compatible NVIDIA GPU (e.g. this sandbox), you need vLLM's
dedicated CPU build. **`pip install vllm --extra-index-url
https://download.pytorch.org/whl/cpu` does not work** — verified against
vLLM 0.27.1 in a fresh venv here. `pip` treats `--extra-index-url` as a
fallback only, and PyPI's default index already has a CUDA-target `torch`
wheel that satisfies vLLM's dependency constraint, so pip installs that one
and never touches the CPU index. The result *installs* cleanly but is
non-functional without a GPU: every `vllm` invocation crashes with
`RuntimeError: Failed to infer device type` (vLLM's platform detection finds
no CUDA device and, because the wheel was built for the CUDA target, no
usable CPU platform either).

The current working method uses [`uv`](https://docs.astral.sh/uv/), which
supports selecting the backend explicitly:

```bash
pip install --upgrade uv
uv venv
uv pip install vllm --torch-backend cpu
```

This still needs `download.pytorch.org` (see the sandbox caveat below) — it
could not be verified end-to-end in this sandbox because that domain is
blocked here. If it's unreachable for you too, fall back to building from
source with the CPU target, per the upstream guide:
https://docs.vllm.ai/en/latest/getting_started/installation/cpu.html

CPU inference is much slower than GPU and is best for small models or
smoke-testing, not production serving.

## Basic usage

```bash
# Start an OpenAI-compatible inference server for a Hugging Face model
vllm serve meta-llama/Llama-3.2-1B-Instruct

# Query it once it's up
curl http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "meta-llama/Llama-3.2-1B-Instruct", "prompt": "Hello,", "max_tokens": 20}'
```

Models are downloaded from the Hugging Face Hub on first use and cached in
`~/.cache/huggingface` — gated models need `huggingface-cli login` or an
`HF_TOKEN` env var first.

Full flag reference: `vllm serve --help` or the
[upstream docs](https://docs.vllm.ai/).

## Sandbox caveat

Serving requires network egress to the Hugging Face Hub (`huggingface.co`,
`cdn-lfs.huggingface.co`) to download model weights, and installation needs
egress to PyPI (`pypi.org`, `files.pythonhosted.org`) and, for both the GPU
build and the real CPU-only build, `download.pytorch.org`. As of this
writing, the Claude Code cloud sandbox's default egress policy blocks
`download.pytorch.org` (confirmed via `curl`: `CONNECT tunnel failed,
response 403`) while allowing `pypi.org`. That means neither the GPU install
nor a genuinely working CPU install can complete in this sandbox unless that
domain is added to the egress policy — `pip install vllm` alone will
succeed but produce the non-functional CUDA-target build described above.
