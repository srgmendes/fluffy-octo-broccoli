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

If there's no compatible NVIDIA GPU (e.g. this sandbox), install the CPU
backend instead, following the upstream instructions:
https://docs.vllm.ai/en/latest/getting_started/installation/cpu.html

```bash
pip install --upgrade pip
pip install vllm --extra-index-url https://download.pytorch.org/whl/cpu
```

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
egress to PyPI (`pypi.org`, `files.pythonhosted.org`) and, for the GPU build,
`download.pytorch.org`. This environment likely has no GPU — use the
CPU-only install above, and make sure the sandbox's egress policy allows
those domains before installing or serving.
