#!/usr/bin/env bash
# Installs guillaumemeyer/watermarks-remover — an agent skill plus a stdlib
# Python HTTP service that strips AI provenance marks (invisible Unicode, C2PA,
# EXIF/XMP, document properties) from text and files you own.
#
# Clones the upstream repo (pinned to $WATERMARKS_VERSION) into ./src, then
# installs the agent skill into the chosen host.
#
# Usage:
#   ./install.sh                      # skill -> ~/.claude/skills (personal)
#   ./install.sh cursor               # skill -> ~/.cursor/skills
#   ./install.sh claude-project /path/to/project   # -> <project>/.claude/skills
#   ./install.sh none                 # clone/update only, install no skill
#
# Env:
#   WATERMARKS_VERSION  upstream git tag to check out (default: v0.6.0)
#   WATERMARKS_SKILL    skill to install (default: remove-ai-marks;
#                       the other is clean-user-facing-text, which is
#                       self-contained and needs no service)
#
# Requirements: git, Python 3.10+ (stdlib only — the service has no deps).
# Optional, auto-used when present: exiftool, qpdf (required for a real PDF
# strip), c2patool. Install via your OS package manager.

set -euo pipefail

VERSION="${WATERMARKS_VERSION:-v0.6.0}"
SKILL="${WATERMARKS_SKILL:-remove-ai-marks}"
TARGET="${1:-claude-code}"
PROJECT_DIR="${2:-}"

cd "$(dirname "$0")"
SRC="$PWD/src"

command -v git >/dev/null 2>&1 || { echo "git is required." >&2; exit 1; }

PYTHON=""
for candidate in python3 py; do
  if command -v "$candidate" >/dev/null 2>&1; then PYTHON="$candidate"; break; fi
done
[ -n "$PYTHON" ] || { echo "Python 3.10+ is required." >&2; exit 1; }

if [ -d "$SRC/.git" ]; then
  echo "Updating existing checkout in src/ to $VERSION"
  git -C "$SRC" fetch --tags --depth 1 origin "$VERSION"
else
  echo "Cloning guillaumemeyer/watermarks-remover@$VERSION into src/"
  git -c advice.detachedHead=false clone --depth 1 --branch "$VERSION" \
    https://github.com/guillaumemeyer/watermarks-remover.git "$SRC"
fi
git -C "$SRC" -c advice.detachedHead=false checkout --quiet "$VERSION"

case "$TARGET" in
  none)
    ;;
  claude-project)
    [ -n "$PROJECT_DIR" ] || { echo "claude-project needs a project path: ./install.sh claude-project /path/to/project" >&2; exit 1; }
    "$PYTHON" "$SRC/install_skill.py" --skill "$SKILL" --target claude-project \
      --project-dir "$PROJECT_DIR"
    ;;
  claude-code|cursor|cowork)
    "$PYTHON" "$SRC/install_skill.py" --skill "$SKILL" --target "$TARGET"
    ;;
  *)
    echo "Unknown target '$TARGET' (expected: claude-code, claude-project, cursor, cowork, none)." >&2
    exit 1
    ;;
esac

echo
echo "Done. Start the service with:"
echo "  $PYTHON $SRC/service/scripts/server.py --host 127.0.0.1 --port 8765"
