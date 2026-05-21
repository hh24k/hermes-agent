# 04 — Troubleshooting

This decodes everything `hermes doctor` might tell you. Findings are grouped by
section, in the same order doctor reports them.

## How to read a doctor report

- ✓ green = working
- ⚠ yellow = optional feature not configured, or fixable issue
- ✗ red = something the agent can't function without

Most warnings are "feature X is available but you haven't opted in." You only
need to act on the ones relevant to your use case.

## Section: Python Environment / Required Packages

| Warning | Meaning | Action |
|---|---|---|
| `python-telegram-bot (optional, not installed)` | You haven't set up the Telegram gateway. | Ignore unless you want phone messaging. See `05-extending.md`. |
| `discord.py (optional, not installed)` | Same for Discord. | Ignore unless using Discord. |
| `Croniter (optional)` shows ✓ but flagged | Used for natural-language cron expressions. Fine if present. | None. |

## Section: Configuration Files

### `model.default 'anthropic/claude-...' uses a vendor/model slug but provider is 'anthropic'`

The native Anthropic provider expects bare model slugs. Vendor-prefixed slugs
(`anthropic/...`) belong to OpenRouter.

**Fix:**

```bash
hermes config set model.default claude-sonnet-4-6
```

Or edit `~/.hermes/config.yaml`:

```yaml
model:
  default: "claude-sonnet-4-6"     # bare slug
  provider: "anthropic"
```

The v2 template ships with this corrected. If you ran `install.sh` recently
the issue is already gone.

## Section: Auth Providers

| Warning | Meaning | Action |
|---|---|---|
| `Nous Portal auth (not logged in)` | You haven't connected a Nous account. | Ignore unless you want Nous-hosted models. |
| `OpenAI Codex auth (not logged in)` | No OpenAI Codex creds. | Ignore unless using OpenAI Codex. |
| `Google Gemini OAuth (not logged in)` | No Gemini OAuth. | Ignore unless using Gemini. |
| `MiniMax OAuth (not logged in)` | No MiniMax (Chinese provider) creds. | Ignore. |

These warnings are aspirational — Hermes lists every provider it *could*
authenticate with. You only need the one(s) you use.

## Section: Command Installation

### `~/.local/bin/hermes points to wrong target`

You have an older Hermes binary symlinked from `~/.local/bin/hermes` to a stale
location (typically `~/.hermes/hermes-agent/venv/bin/hermes` from the curl
installer).

**Fix:**

```bash
hermes doctor --fix
```

Then optionally remove the stale install:

```bash
rm -rf ~/.hermes/hermes-agent     # ONLY this subfolder, NOT ~/.hermes itself
```

## Section: External Tools

| Warning | Action |
|---|---|
| `agent-browser not installed (run: npm install)` | `cd ~/Documents/GitHub/community/hermes-agent && npm install`. Enables real browser automation. |
| `docker (optional)` shows ⚠ if not installed | Only needed if you set `terminal.backend: docker`. Skip otherwise. |

## Section: API Connectivity

| Warning | Meaning | Action |
|---|---|---|
| `OpenRouter API (not configured)` | No `OPENROUTER_API_KEY` set. | Add one to unlock fallback chain + `moa` tool. See `05-extending.md`. |
| `Anthropic API` ✓ | Working. | None. |

## Section: Submodules

### `tinker-atropos not found`

Only matters if you're doing reinforcement-learning training with Hermes —
which you're not. Ignore.

If you ever do need it:
```bash
cd ~/Documents/GitHub/community/hermes-agent
git submodule update --init --recursive
```

## Section: Tool Availability

Every warning here means "I have the code for this tool, but the system
dependency or API key is missing." Triage:

### Worth enabling (cheap, useful for your goals)

| Tool | Missing | How to enable |
|---|---|---|
| `web` (better search) | `EXA_API_KEY` or `TAVILY_API_KEY` or `FIRECRAWL_API_KEY` | Get a key, add to `~/.hermes/.env`. See `05-extending.md`. |
| `moa` (mixture-of-agents) | `OPENROUTER_API_KEY` | Add to `~/.hermes/.env`. Lets Hermes ask multiple models and ensemble. |

### Safe to ignore (irrelevant to dev/learning/investment)

| Tool | Why ignore |
|---|---|
| `discord`, `discord_admin` | You said CLI only. |
| `messaging` | Same. |
| `feishu_doc`, `feishu_drive` | Chinese collaboration tools. |
| `hermes-yuanbao` | Tencent integration. |
| `homeassistant` | Smart home — not your use case. |
| `spotify` | Music control. |
| `image_gen`, `video_gen` | Generative media. Add Replicate/Flux/etc. only if you want this. |
| `rl` (`TINKER_API_KEY`, `WANDB_API_KEY`) | RL training. Not relevant. |
| `computer_use` | Anthropic's experimental computer control API. Enable later if you want it. |
| `browser-cdp` | Lower-level Chrome control. The standard `browser` tool covers normal use once `npm install` is done. |

## Section: Skills Hub

### `Skills Hub directory not initialized (run: hermes skills list)`

The community skill registry isn't cached locally yet.

**Fix:**

```bash
hermes skills list
```

This pulls the index. Browse with `hermes skills search <keyword>`.

### `No GITHUB_TOKEN`

You're rate-limited to 60 GitHub API requests/hour, which gets eaten quickly
when browsing skills or analyzing repos.

**Fix:**

1. Go to <https://github.com/settings/tokens/new> and generate a **classic
   token with NO scopes** (no permissions needed — just want higher rate
   limits).
2. Add to `~/.hermes/.env`:
   ```
   GITHUB_TOKEN=ghp_...
   ```

## Common runtime issues (not from doctor)

### "Out of extra usage" when using Anthropic OAuth

You authenticated via OAuth (Claude Max plan) but only the *extra/overage*
credits feed Hermes — the base Max plan allowance doesn't apply. Either buy
extra usage at <https://claude.ai/settings/usage>, or switch to a pay-per-token
API key:

```bash
hermes auth add anthropic --type api-key --api-key sk-ant-api03-...
```

### Random `401 Bearer None` errors

Stale token in `.env` after rotating OAuth elsewhere. Run:

```bash
hermes config set ANTHROPIC_TOKEN ""
hermes config set ANTHROPIC_API_KEY ""
# then re-add via:
hermes auth
```

### Auxiliary task errors mentioning OpenRouter

You have the wrong auxiliary config. Make sure your `config.yaml` has:

```yaml
auxiliary:
  vision:      { provider: "main" }
  web_extract: { provider: "main" }
  compression: { provider: "main" }
```

The v2 template ships with this set.

### Context window errors at startup

```
Model X has only 32K context, Hermes requires >=64K
```

Either pick a different model, or for Ollama set `OLLAMA_CONTEXT_LENGTH=65536`
before starting `ollama serve`, and `context_length: 65536` under
`providers.ollama` in `config.yaml`.

### `hermes` command not found after install

The binary lives in the repo's `.venv/bin/`. Either activate the venv, run
`hermes doctor --fix` (creates a global symlink), or add it to PATH manually.
See `01-installation.md` "Make `hermes` available everywhere".

## When in doubt

```bash
hermes doctor                       # tells you what's wrong
hermes doctor --fix                 # tries to fix it
cat ~/.hermes/logs/agent.log        # last session details
```

If a problem isn't covered here, the official docs are at
<https://hermes-agent.nousresearch.com/docs/> and the GitHub issues at
<https://github.com/NousResearch/hermes-agent/issues> are reasonably active.
