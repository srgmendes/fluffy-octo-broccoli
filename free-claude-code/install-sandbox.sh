#!/bin/sh
# Install Free Claude Code (FCC) inside the Claude Code cloud sandbox, whose
# egress proxy blocks the hosts the upstream one-liner needs. This script uses
# only sanctioned lanes: the git proxy (public GitHub reads), PyPI, and
# static.crates.io. It installs Claude Code support only -- Codex (chatgpt.com)
# and Pi (pi.dev) installer hosts are blocked in the sandbox.
#
# On a normal, unrestricted machine you do NOT need this -- use the upstream
# installer instead:
#   curl -fsSL "https://raw.githubusercontent.com/Alishahryar1/free-claude-code/main/scripts/install.sh" | sh
#
# Usage:
#   sh free-claude-code/install-sandbox.sh
#
# Overridable via environment:
#   CLONE_DIR           where to clone the FCC source (default: /workspace/alishahryar1/free-claude-code)
#   TIKTOKEN_CACHE_DIR  where to seed tiktoken vocab (default: $HOME/.cache/tiktoken)
#   PYTHON_VERSION      CPython to provision with uv (default: 3.14.0)
set -eu

REPO_URL="https://github.com/Alishahryar1/free-claude-code"
CLONE_DIR="${CLONE_DIR:-/workspace/alishahryar1/free-claude-code}"
PYTHON_VERSION="${PYTHON_VERSION:-3.14.0}"
MIN_UV_VERSION="0.11.16"
TIKTOKEN_CACHE_DIR="${TIKTOKEN_CACHE_DIR:-$HOME/.cache/tiktoken}"
# Tools that use Node's built-in fetch must honour the proxy in the sandbox.
export NODE_USE_ENV_PROXY=1

# tiktoken verifies each vocab file against these known sha256 values, so the
# source of the bytes does not matter -- the hash guarantees the official file.
CL100K_SHA256="223921b76ee99bde995b7ff738513eef100fb51d18c93597a113bcffe865b2a7"
O200K_SHA256="446a9538cb6c348e3516120d7c08b09f57c36495e2acfffe59a5bf8b0cfb1a2d"

step() { printf '\n==> %s\n' "$1"; }
fail() { printf 'error: %s\n' "$*" >&2; exit 1; }

require() { command -v "$1" >/dev/null 2>&1 || fail "$1 is required but not found."; }
require git; require curl; require tar; require python3

# --- 1. FCC source via the git proxy (the archive URL is blocked) ------------
step "Fetching Free Claude Code source via the git proxy"
if git -C "$CLONE_DIR" rev-parse --git-dir >/dev/null 2>&1; then
    echo "Existing clone at $CLONE_DIR; updating."
    GIT_LFS_SKIP_SMUDGE=1 git -C "$CLONE_DIR" fetch --depth 1 origin HEAD
    GIT_LFS_SKIP_SMUDGE=1 git -C "$CLONE_DIR" reset --hard FETCH_HEAD
else
    mkdir -p "$(dirname "$CLONE_DIR")"
    GIT_LFS_SKIP_SMUDGE=1 git clone --depth 1 "$REPO_URL" "$CLONE_DIR"
fi

# --- 2. uv >= 0.11.16 from PyPI (astral.sh is blocked) -----------------------
step "Ensuring uv >= $MIN_UV_VERSION (from PyPI)"
uv_ok=0
if command -v uv >/dev/null 2>&1; then
    # Compare the installed uv version against the minimum in python (portable).
    cur=$(uv --version 2>/dev/null | awk '{print $2}')
    if python3 - "$cur" "$MIN_UV_VERSION" <<'PY'
import sys
def parse(v):
    v = v.split('+')[0].split('-')[0]
    return [int(x) for x in v.split('.') if x.isdigit()]
sys.exit(0 if parse(sys.argv[1]) >= parse(sys.argv[2]) else 1)
PY
    then uv_ok=1; else uv_ok=0; fi
fi
if [ "$uv_ok" -eq 1 ]; then
    echo "uv $(uv --version | awk '{print $2}') already satisfies >= $MIN_UV_VERSION."
else
    echo "Installing/upgrading uv from PyPI..."
    python3 -m pip install --user --upgrade "uv>=$MIN_UV_VERSION" \
        || python3 -m pip install --user --break-system-packages --upgrade "uv>=$MIN_UV_VERSION"
    hash -r 2>/dev/null || true
fi
require uv

# --- 3. Python 3.14 final (rc releases crash on pydantic prefer_fwd_module) --
step "Provisioning CPython $PYTHON_VERSION with uv"
uv python install "$PYTHON_VERSION"

# --- 4. Install FCC from the local clone (deps resolve from PyPI) -------------
step "Installing Free Claude Code as a uv tool"
uv tool install --force --python "$PYTHON_VERSION" "$CLONE_DIR"
uv tool update-shell 2>/dev/null || true
TOOL_BIN="$(uv tool dir --bin)"
PATH="$TOOL_BIN:$PATH"; export PATH; hash -r 2>/dev/null || true

# --- 5. Seed the tiktoken vocab cache from the tiktoken-rs crate -------------
step "Seeding the tiktoken vocab cache (openaipublic blob host is blocked)"
mkdir -p "$TIKTOKEN_CACHE_DIR"
TT_VER=$(curl -fsSL --max-time 20 "https://index.crates.io/ti/kt/tiktoken-rs" 2>/dev/null \
    | tail -1 | python3 -c "import sys,json;print(json.loads(sys.stdin.read())['vers'])" 2>/dev/null || true)
TT_VER="${TT_VER:-0.12.0}"
echo "Using tiktoken-rs $TT_VER from static.crates.io"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
curl -fsSL --max-time 120 "https://static.crates.io/crates/tiktoken-rs/tiktoken-rs-${TT_VER}.crate" -o "$work/tt.crate"
tar -xzf "$work/tt.crate" -C "$work"
assets="$work/tiktoken-rs-${TT_VER}/assets"
python3 - "$assets" "$TIKTOKEN_CACHE_DIR" "$CL100K_SHA256" "$O200K_SHA256" <<'PY'
import hashlib, os, shutil, sys
assets, cache, cl_sha, o2_sha = sys.argv[1:5]
base = "https://openaipublic.blob.core.windows.net/encodings/"
want = {"cl100k_base": cl_sha, "o200k_base": o2_sha}
for name, expected in want.items():
    src = os.path.join(assets, f"{name}.tiktoken")
    got = hashlib.sha256(open(src, "rb").read()).hexdigest()
    if got != expected:
        sys.exit(f"sha256 mismatch for {name}: {got} != {expected}")
    key = hashlib.sha1((base + name + ".tiktoken").encode()).hexdigest()
    shutil.copyfile(src, os.path.join(cache, key))
    print(f"  {name}: verified {expected[:12]}... -> {key}")
PY

# --- 6. Verify ---------------------------------------------------------------
step "Verifying"
"$TOOL_BIN/fcc-server" --version

cat <<EOF

Free Claude Code is installed. Start the proxy with:

  TIKTOKEN_CACHE_DIR=$TIKTOKEN_CACHE_DIR NODE_USE_ENV_PROXY=1 fcc-server

Then open the Admin UI at http://127.0.0.1:8082/admin to configure a provider,
and run Claude Code through it with:  fcc-claude

Note: provider APIs and the Codex/Pi installers are blocked by the sandbox
egress policy, so real proxying must be done from an unrestricted environment.
EOF
