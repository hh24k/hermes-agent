#!/usr/bin/env bash
# =============================================================================
# Hermes Agent — local install/configure script for macOS
# =============================================================================
# Run from the repo root:
#   cd ~/Documents/GitHub/community/hermes-agent
#   bash _my-setup/install.sh
#
# Idempotent — safe to re-run after editing templates. It will:
#   1. Check prerequisites (uv, Python 3.11, Node.js, ripgrep, ffmpeg)
#   2. Install Hermes Agent from this repo (editable mode) into .venv
#   3. Create ~/.hermes/ and copy templates in (backing up any existing files)
#   4. Detect and warn about the stale ~/.hermes/hermes-agent install if any
#   5. Print next steps
# =============================================================================

set -euo pipefail

# Colors
G='\033[0;32m'; Y='\033[1;33m'; R='\033[0;31m'; B='\033[0;34m'; N='\033[0m'
say()  { echo -e "${B}==>${N} $*"; }
ok()   { echo -e "${G}✓${N} $*"; }
warn() { echo -e "${Y}!${N} $*"; }
err()  { echo -e "${R}✗${N} $*" >&2; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
HERMES_DIR="$HOME/.hermes"
TEMPLATES_DIR="$SCRIPT_DIR/templates"

say "Hermes Agent installer (v2)"
echo "  Repo:      $REPO_DIR"
echo "  Templates: $TEMPLATES_DIR"
echo "  Config:    $HERMES_DIR"
echo

# ─── 1. Sanity checks ────────────────────────────────────────────────────────
[ -f "$REPO_DIR/pyproject.toml" ]                    || { err "Not in the hermes-agent repo root (no pyproject.toml)."; exit 1; }
[ -f "$TEMPLATES_DIR/env.template" ]                 || { err "Missing $TEMPLATES_DIR/env.template"; exit 1; }
[ -f "$TEMPLATES_DIR/config.yaml.template" ]         || { err "Missing $TEMPLATES_DIR/config.yaml.template"; exit 1; }

# ─── 2. Prerequisites ────────────────────────────────────────────────────────
say "Checking prerequisites"

need_brew=()
command -v uv >/dev/null         || need_brew+=("uv")
command -v node >/dev/null       || need_brew+=("node")
command -v rg >/dev/null         || need_brew+=("ripgrep")
command -v ffmpeg >/dev/null     || need_brew+=("ffmpeg")

if [ ${#need_brew[@]} -gt 0 ]; then
  warn "Missing tools: ${need_brew[*]}"
  if command -v brew >/dev/null; then
    say "Installing via Homebrew..."
    brew install "${need_brew[@]}"
  else
    err "Homebrew not found. Install it: https://brew.sh"
    err "Or install manually: ${need_brew[*]}"
    exit 1
  fi
fi

# Python 3.11 via uv (Hermes pins this)
if ! uv python list 2>/dev/null | grep -q '3.11'; then
  say "Installing Python 3.11 via uv"
  uv python install 3.11
fi
ok "Prerequisites ready"

# ─── 3. Install Hermes in editable mode ──────────────────────────────────────
say "Installing Hermes Agent (editable mode)"

# venv lives inside the repo so it's self-contained (uninstall = rm -rf .venv)
if [ ! -d "$REPO_DIR/.venv" ]; then
  uv venv --python 3.11 "$REPO_DIR/.venv"
fi
# shellcheck disable=SC1091
source "$REPO_DIR/.venv/bin/activate"

cd "$REPO_DIR"
if ! uv pip install -e ".[full]" 2>/dev/null; then
  warn "'.[full]' extra not available, installing base package only"
  uv pip install -e "."
fi
ok "Hermes installed: $(command -v hermes 2>/dev/null || echo '(check .venv/bin/hermes)')"

# ─── 4. Optional: agent-browser (Node-based browser automation) ──────────────
if [ -f "$REPO_DIR/package.json" ]; then
  say "Installing agent-browser (Node deps)"
  cd "$REPO_DIR"
  if npm install >/dev/null 2>&1; then
    ok "agent-browser ready"
  else
    warn "npm install failed — skip; you can run it manually later"
  fi
fi

# ─── 5. Configure ~/.hermes ──────────────────────────────────────────────────
say "Setting up $HERMES_DIR"
mkdir -p "$HERMES_DIR"

backup_if_exists() {
  local f="$1"
  if [ -f "$f" ]; then
    local bak="${f}.bak.$(date +%Y%m%d-%H%M%S)"
    cp "$f" "$bak"
    warn "Existing $(basename "$f") backed up to $bak"
  fi
}

backup_if_exists "$HERMES_DIR/.env"
backup_if_exists "$HERMES_DIR/config.yaml"

cp "$TEMPLATES_DIR/env.template"          "$HERMES_DIR/.env"
cp "$TEMPLATES_DIR/config.yaml.template"  "$HERMES_DIR/config.yaml"
chmod 600 "$HERMES_DIR/.env"

ok "Wrote $HERMES_DIR/.env and $HERMES_DIR/config.yaml"

# ─── 6. Detect stale legacy install ──────────────────────────────────────────
STALE_DIR="$HERMES_DIR/hermes-agent"
if [ -d "$STALE_DIR" ]; then
  warn "Detected an older Hermes install at $STALE_DIR"
  warn "After verifying this new install works, you can remove it:"
  echo "    rm -rf $STALE_DIR"
fi

# Check the /usr/local symlink situation
if [ -L "$HOME/.local/bin/hermes" ]; then
  TARGET="$(readlink "$HOME/.local/bin/hermes")"
  EXPECTED="$REPO_DIR/.venv/bin/hermes"
  if [ "$TARGET" != "$EXPECTED" ]; then
    warn "~/.local/bin/hermes points to: $TARGET"
    warn "Expected: $EXPECTED"
    warn "Fix it with: hermes doctor --fix"
  fi
fi

# ─── 7. Smoke test ───────────────────────────────────────────────────────────
say "Verifying install"
if hermes --version >/dev/null 2>&1; then
  ok "hermes CLI works: $(hermes --version 2>&1 | head -1)"
else
  warn "hermes command not on global PATH."
  warn "Either activate the venv:"
  echo "    source $REPO_DIR/.venv/bin/activate"
  warn "Or add it to PATH:"
  echo "    echo 'export PATH=\"$REPO_DIR/.venv/bin:\$PATH\"' >> ~/.zshrc"
fi

echo
echo "═══════════════════════════════════════════════════════════════════════"
echo -e "${G}Setup complete.${N}"
echo "═══════════════════════════════════════════════════════════════════════"
echo
echo "NEXT STEPS:"
echo
echo "  1. Paste your real Anthropic API key:"
echo "     \$EDITOR ~/.hermes/.env"
echo
echo "  2. Run the doctor to verify and auto-fix any issues:"
echo "     hermes doctor"
echo "     hermes doctor --fix"
echo
echo "  3. Start chatting:"
echo "     hermes"
echo
echo "  Docs:"
echo "    Quick start:    $SCRIPT_DIR/README.md"
echo "    Configuration:  $SCRIPT_DIR/docs/02-configuration.md"
echo "    Daily usage:    $SCRIPT_DIR/docs/03-daily-usage.md"
echo "    Troubleshoot:   $SCRIPT_DIR/docs/04-troubleshooting.md"
echo
