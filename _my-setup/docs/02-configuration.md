# 02 — Configuration

Two files in `~/.hermes/`:

- **`.env`** — secrets (API keys, tokens). chmod 600. Never commit.
- **`config.yaml`** — everything else (model, fallback, memory, tools).

Edit them directly, or use `hermes config set KEY VAL` which auto-routes to
the right file.

## Settings precedence

Highest to lowest:

1. **CLI flags** — `hermes chat --model claude-opus-4-7` (one-shot)
2. **`~/.hermes/config.yaml`** — your persistent settings
3. **`~/.hermes/.env`** — fallback for env vars; required for secrets
4. **Built-in defaults**

## Model slug formats — IMPORTANT

The format depends on which provider you're using:

| Provider                | Slug format                        | Example                              |
|-------------------------|------------------------------------|--------------------------------------|
| Native Anthropic        | `<model>` (BARE)                   | `claude-sonnet-4-6`                  |
| OpenRouter aggregator   | `<vendor>/<model>` (vendor-prefix) | `anthropic/claude-sonnet-4-6`        |
| Custom (Ollama et al.)  | `custom:<name>:<model>`            | `custom:ollama:qwen2.5-coder:32b`    |

Mixing them — e.g. `provider: anthropic` with `model.default: anthropic/...` —
makes `hermes doctor` warn and may cause routing errors.

## What's in `config.yaml`

### `model` — the default

```yaml
model:
  default: "claude-sonnet-4-6"
  provider: "anthropic"
```

Common swaps:

```yaml
# Smartest, pricier — for hard problems
model: { default: "claude-opus-4-7",   provider: "anthropic" }

# Cheapest, fastest — for high-volume drudgework
model: { default: "claude-haiku-4-5",  provider: "anthropic" }

# Through OpenRouter (load balancing, fallback chain access)
model: { default: "anthropic/claude-sonnet-4-6", provider: "openrouter" }
```

### `fallback_providers` — automatic failover

```yaml
fallback_providers:
  - provider: openrouter
    model: anthropic/claude-sonnet-4
```

Fires at most once per session when the primary hits rate-limits, 5xx, or auth
errors. Conversation continues uninterrupted on the fallback. Add more entries
(tried in order) for a longer chain.

### `auxiliary` — vision, summarization, compression

```yaml
auxiliary:
  vision:        { provider: "main" }
  web_extract:   { provider: "main" }
  compression:   { provider: "main" }
  skill_matching:{ provider: "main" }
  memory:        { provider: "main" }
```

**This is the #1 setting people get wrong.** Without `provider: "main"`, all
auxiliary tasks try OpenRouter first. If you only have an Anthropic key, vision
and web-summarization will silently fail. Keep these as-is unless you
specifically want auxiliary tasks routed elsewhere.

### `providers` — custom endpoints

```yaml
providers:
  ollama:
    base_url: "http://localhost:11434/v1"
    api_key:  "ollama"
    context_length: 65536
```

Add OpenAI-compatible endpoints here (LM Studio, vLLM, llama.cpp). They become
addressable as `custom:<name>:<model>` in chat.

### `terminal` — where the agent runs commands

```yaml
terminal:
  backend: "local"      # "local" | "docker" | "ssh"
  cwd: "."
```

`local` for normal use. `docker` if you're letting the agent run autonomously
and want sandboxing. `ssh` for remote-box workflows.

### `memory` and `skills` — the Hermes-specific value

```yaml
memory:
  memory_enabled: true        # remember facts across sessions
  user_profile_enabled: true  # build a model of who you are
  memory_char_limit: 2200     # per turn injection cap
  user_char_limit: 1375

skills:
  guard_agent_created: false  # set true to confirm every skill the agent writes
```

These are what differentiate Hermes from plain Claude. Leave them on.

## What's in `.env`

| Variable             | Required | Purpose                                     |
|----------------------|----------|---------------------------------------------|
| `ANTHROPIC_API_KEY`  | ✅       | Primary provider                            |
| `OPENROUTER_API_KEY` | recommended | Fallback chain + `moa` tool              |
| `GITHUB_TOKEN`       | recommended | Higher GitHub rate limits                |
| `EXA_API_KEY`        | optional | Best semantic search                        |
| `TAVILY_API_KEY`     | optional | General-purpose search (free tier)          |
| `FIRECRAWL_API_KEY`  | optional | Site scraping                               |
| `GOOGLE_API_KEY`     | optional | Gemini vision alternative                   |
| `GROQ_API_KEY`       | optional | Voice transcription                         |
| `TELEGRAM_BOT_TOKEN` | optional | Messaging gateway                           |

## Changing settings safely

```bash
# Routes secrets to .env, everything else to config.yaml automatically:
hermes config set model.default claude-opus-4-7
hermes config set OPENROUTER_API_KEY sk-or-v1-...
hermes config set memory.memory_char_limit 3000

# Or open the file directly:
$EDITOR ~/.hermes/config.yaml
```

After major changes, run `hermes doctor` to verify nothing's broken.

## Reverting / re-applying the template

To go back to your repo's template defaults:

```bash
cd ~/Documents/GitHub/community/hermes-agent
bash _my-setup/install.sh
# The installer backs up your current .env / config.yaml before overwriting.
```
