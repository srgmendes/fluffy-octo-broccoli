#!/usr/bin/env bash
# Installs the vLLM CLI/library (https://github.com/vllm-project/vllm.git) via
# pipx, falling back to `pip3 install --user` if pipx isn't available.
#
# Usage:
#   ./install.sh
#
# Requirements: Linux, Python 3.9-3.12. The default `pip install vllm` pulls
# in PyTorch and CUDA libraries and targets an NVIDIA GPU host. On a machine
# without a compatible GPU (e.g. this sandbox), skip this script and follow
# the CPU-only install instructions in README.md instead.

set -euo pipefail

if command -v pipx >/dev/null 2>&1; then
  pipx install vllm
elif command -v pip3 >/dev/null 2>&1; then
  echo "pipx not found; falling back to 'pip3 install --user vllm'" >&2
  pip3 install --user vllm
else
  echo "Neither pipx nor pip3 found. Install Python 3.9-3.12 first." >&2
  exit 1
fi

vllm --version
