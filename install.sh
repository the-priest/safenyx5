#!/usr/bin/env bash
# Nyx v0.1 installer
#
# Installs Python deps (groq), makes nyx.py executable, symlinks to PATH.
# Does NOT use sudo, does NOT install system packages.

set -e

if [ -t 1 ]; then
  RED=$'\033[31m'; GRN=$'\033[32m'; YEL=$'\033[33m'
  CYN=$'\033[36m'; DIM=$'\033[90m'; RST=$'\033[0m'; BLD=$'\033[1m'
  NIGHT=$'\033[94m'
else
  RED=""; GRN=""; YEL=""; CYN=""; DIM=""; RST=""; BLD=""; NIGHT=""
fi

say()  { printf "%s\n" "${NIGHT}[nyx]${RST} $*"; }
ok()   { printf "%s\n" "${GRN}  ✓${RST} $*"; }
warn() { printf "%s\n" "${YEL}  ⚠${RST} $*"; }
err()  { printf "%s\n" "${RED}  ✕${RST} $*"; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NYX_PY="$SCRIPT_DIR/nyx.py"

if [ ! -f "$NYX_PY" ]; then
  err "nyx.py not found in $SCRIPT_DIR"
  exit 1
fi

say "Nyx v0.1 installer  ${DIM}(primordial goddess of night)${RST}"
say "working from: $SCRIPT_DIR"
echo

# Python check
if ! command -v python3 >/dev/null 2>&1; then
  err "python3 not installed — install python3 (>= 3.10) first"
  exit 1
fi
PY_VER=$(python3 -c 'import sys; print("{}.{}".format(*sys.version_info[:2]))')
PY_MAJOR=$(echo "$PY_VER" | cut -d. -f1)
PY_MINOR=$(echo "$PY_VER" | cut -d. -f2)
if [ "$PY_MAJOR" -lt 3 ] || { [ "$PY_MAJOR" -eq 3 ] && [ "$PY_MINOR" -lt 10 ]; }; then
  err "python $PY_VER detected — Nyx needs Python 3.10+"
  exit 1
fi
ok "python3 $PY_VER"

# Python deps
say "installing python deps..."
if [ -f "$SCRIPT_DIR/requirements.txt" ]; then
  if pip install -r "$SCRIPT_DIR/requirements.txt" >/dev/null 2>&1; then
    ok "requirements.txt installed (pip)"
  elif pip install -r "$SCRIPT_DIR/requirements.txt" --break-system-packages >/dev/null 2>&1; then
    ok "requirements.txt installed (--break-system-packages)"
  elif pip install -r "$SCRIPT_DIR/requirements.txt" --user >/dev/null 2>&1; then
    ok "requirements.txt installed (--user)"
  else
    err "pip failed — nyx needs the groq python package"
    err "  try manually: pip install groq --break-system-packages"
    exit 1
  fi
fi

# Executable + symlink
chmod +x "$NYX_PY"
ok "nyx.py marked executable"

BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"
LINK="$BIN_DIR/nyx"
ln -sf "$NYX_PY" "$LINK"
ok "symlinked $LINK → $NYX_PY"

case ":$PATH:" in
  *":$BIN_DIR:"*) ok "$BIN_DIR is on PATH" ;;
  *)
    warn "$BIN_DIR is NOT on PATH — add to your shell rc:"
    warn "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    ;;
esac

# Pantheon detection
echo
say "checking for pantheon tools..."
for tool in zeus ares hades; do
  if command -v "$tool" >/dev/null 2>&1; then
    ok "$tool found"
  else
    warn "$tool not in PATH — nyx won't be able to call it"
  fi
done

# Groq check
echo
if [ -n "${GROQ_API_KEY:-}" ]; then
  ok "GROQ_API_KEY set"
else
  err "GROQ_API_KEY not set — Nyx CANNOT run without it"
  err "  get a free key: https://console.groq.com"
  err "  then: export GROQ_API_KEY=gsk_..."
fi

echo
say "${BLD}done.${RST}  run:  ${NIGHT}nyx${RST}"
echo
echo "${DIM}  Nyx is experimental.  Day one she is blank.${RST}"
echo "${DIM}  Useful behavior emerges after ~24-48h of real use.${RST}"
echo "${DIM}  Read [LOCKED] sections in nyx.py before modifying.${RST}"
