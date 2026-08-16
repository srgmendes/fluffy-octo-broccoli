#!/usr/bin/env bash
# Clones guillaumemeyer/watermarks-remover (https://github.com/guillaumemeyer/watermarks-remover)
# into a git-ignored checkout/ subdirectory. There's no PyPI package for this
# tool, so it's run directly from a local clone rather than pip-installed.
#
# Usage:
#   ./install.sh
#
# Requirements: git, Python 3.10+. Optional: exiftool, qpdf, c2patool for full
# metadata-stripping coverage (see checkout/README.md after cloning).

set -euo pipefail

cd "$(dirname "$0")"

if [ -d checkout/.git ]; then
  echo "checkout/ already exists; pulling latest instead of re-cloning" >&2
  git -C checkout pull --ff-only
else
  git clone https://github.com/guillaumemeyer/watermarks-remover.git checkout
fi

echo "Cloned to $(pwd)/checkout"
echo "Next: cd checkout && python3 service/scripts/clean_file.py --help"
