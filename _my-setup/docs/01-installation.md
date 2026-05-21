# 01 — Installation

## Prerequisites

The installer auto-installs missing pieces via Homebrew. Manual reference:

| Tool      | Purpose                                          | Install                    |
|-----------|--------------------------------------------------|----------------------------|
| `uv`      | Fast Python package manager + Python 3.11        | `brew install uv`          |
| `node`    | Powers agent-browser and the web UI              | `brew install node`        |
| `ripgrep` | Fast in-repo code search used by the agent       | `brew install ripgrep`     |
| `ffmpeg`  | Audio/video for voice features                   | `brew install ffmpeg`      |

If you don't have Homebrew: <https://brew.sh>

## Run the installer

```bash
cd ~/Documents/GitHub/community/hermes-agent
bash _my-setup/install.sh
```

It does the following, in order:

1. Verifies you're in the repo root (looks for `pyproject.toml`).
2. Installs any missing prerequisites via `brew`.
3. Creates a Python 3.11 venv at `.venv/` inside the repo.
4. Runs `uv pip install -e ".[full]"` (or base if `[full]` extra isn't on your tag).
5. Runs `npm install` if `package.json` exists (enables agent-browser).
6. Copies `templates/env.template` → `~/.hermes/.env` (backing up any existing).
7. Copies `templates/config.yaml.template` → `~/.hermes/config.yaml` (with backup).
8. Detects stale `~/.hermes/hermes-agent/` from the curl-installer path and warns.
9. Verifies the `hermes` CLI is reachable.

It's idempotent — safe to re-run any time you edit a template.

## Make `hermes` available everywhere

After the installer, two options:

### Option A — Use the venv directly

```bash
source ~/Documents/GitHub/community/hermes-agent/.venv/bin/activate
hermes
```

### Option B — Let `hermes doctor --fix` handle the symlink

```bash
hermes doctor --fix
```

This points `~/.local/bin/hermes` at the right venv binary. As long as
`~/.local/bin` is on your `$PATH` (default on macOS), `hermes` works from any
shell.

### Option C — Add the venv to PATH manually

```bash
echo 'export PATH="$HOME/Documents/GitHub/community/hermes-agent/.venv/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## First-time API key setup

```bash
$EDITOR ~/.hermes/.env
```

Replace `sk-ant-api03-REPLACE_ME` with a real key from
<https://console.anthropic.com/settings/keys>.

That's the only required field. The rest of `.env` is commented placeholders
for things you may add later (OpenRouter, EXA, GitHub token, etc.) — see
`05-extending.md`.

## Verify

```bash
hermes doctor          # diagnose
hermes doctor --fix    # auto-repair what's possible
hermes                 # start chatting — `/quit` exits
```

Expected end state: green checks, the only warnings should be for
optional integrations you didn't enable. See `04-troubleshooting.md` for what
each warning means.

## Clean up the old install (if you had one)

The first run of `install.sh` will warn you if `~/.hermes/hermes-agent/` exists
from a previous curl-installer attempt. After confirming the new install works:

```bash
rm -rf ~/.hermes/hermes-agent     # ONLY this subfolder — keep ~/.hermes itself
```

## Updating

```bash
cd ~/Documents/GitHub/community/hermes-agent
git pull
bash _my-setup/install.sh         # idempotent, reinstalls deps
```

Or the built-in updater:

```bash
hermes update
```

## Uninstall

```bash
# 1. The install
rm -rf ~/Documents/GitHub/community/hermes-agent/.venv

# 2. Config + memory (BACK UP ~/.hermes/memories/ FIRST if you care about it)
cp -r ~/.hermes/memories ~/Desktop/hermes-memories-backup
rm -rf ~/.hermes

# 3. The repo (optional)
rm -rf ~/Documents/GitHub/community/hermes-agent
```
