# 03 — Daily usage

## Starting a session

```bash
hermes                                  # interactive chat
hermes --model claude-opus-4-7          # one-shot model override
hermes --resume                         # resume last session
```

## Slash commands (inside chat)

| Command | Effect |
|---|---|
| `/help` | List all commands |
| `/model` | Interactive model picker |
| `/model <id>` | Switch model immediately (e.g. `/model claude-opus-4-7`) |
| `/memory` | View / edit what Hermes remembers about you & your projects |
| `/skills` | List, run, or edit saved skills |
| `/tools` | Show available tools (terminal, web, browser, etc.) |
| `/compress` | Manually compress chat history if you're running long |
| `/clear` | Drop history for a fresh start (memory stays) |
| `/quit` | Exit |

## CLI commands (outside chat)

```bash
hermes doctor                  # diagnose config + connectivity
hermes doctor --fix            # auto-repair what's auto-fixable
hermes model                   # switch provider/model permanently
hermes tools                   # enable/disable tool categories
hermes auth list               # see all credentials Hermes knows about
hermes config set KEY VAL      # edit safely (routes to .env or config.yaml)
hermes skills list             # browse the Skills Hub (community skills)
hermes gateway setup           # interactive wizard for messaging platforms
hermes update                  # pull upstream + reinstall
hermes --version
```

## Switching models — the three ways

### One-shot, for this session only

In chat:
```
/model claude-opus-4-7
/model custom:ollama:qwen2.5-coder:32b
```

### Per-invocation override

```bash
hermes --model claude-opus-4-7
```

### Permanent (next time you start `hermes`)

```bash
hermes model              # interactive wizard
# or edit config.yaml: model.default: "..."
```

## Using local LLM (Ollama)

Already pre-wired in `config.yaml`. To use it for real:

```bash
# 1. Install Ollama
brew install ollama

# 2. Start with a 64K context window (Hermes minimum)
OLLAMA_CONTEXT_LENGTH=65536 ollama serve

# 3. In another terminal, pull a model
ollama pull qwen2.5-coder:32b      # great for code
# or
ollama pull llama3.1:70b           # general-purpose
ollama pull deepseek-r1:32b        # reasoning-heavy tasks

# 4. Use it in Hermes
hermes
> /model custom:ollama:qwen2.5-coder:32b
```

To make a local model the **default**, edit `~/.hermes/config.yaml`:

```yaml
model:
  default: "qwen2.5-coder:32b"
  provider: "ollama"
```

## Memory hygiene

Hermes accumulates facts about you and your projects in
`~/.hermes/memories/MEMORY.md` and `~/.hermes/memories/USER.md`.

```bash
# View / prune from inside chat:
/memory

# Or edit directly:
$EDITOR ~/.hermes/memories/MEMORY.md
$EDITOR ~/.hermes/memories/USER.md
```

**Back up `~/.hermes/memories/` periodically** — it's the value you've built up
over time. The rest of `~/.hermes/` can be regenerated.

## Skills — the real long-term payoff

When Hermes solves a non-trivial problem well, it can save a reusable "skill"
that gets matched and loaded automatically next time you ask something similar.

```bash
# List your skills + Hub skills you've installed:
hermes skills list

# Browse the community Skills Hub:
hermes skills search "investment"
hermes skills search "code review"

# Install one:
hermes skills install <name>
```

Saved skills live in `~/.hermes/skills/`. They're versioned Markdown files —
read and edit them like any other doc.

## Useful patterns for your goals

### Daily dev work

```bash
cd ~/Projects/some-project
hermes                                                 # picks up cwd context
> "review the PR I'm about to push, check tests"
> /tools terminal browser                              # ensure these are on
```

### Self-learning

Use longer sessions and let memory accumulate. Ask follow-up questions across
days — Hermes will recall what you covered.

```
> "yesterday we covered Rust ownership. today I want to dig into lifetimes
   in async functions specifically."
```

### Investment research

Add EXA + Firecrawl keys (see `05-extending.md`). Then:

```
> "pull the latest 10-Q for $TICKER, summarize the risk factors section,
   and tell me what changed vs last quarter."
```

### Self-dev (scheduled jobs)

```bash
# Tell Hermes once, it sets up a cron entry:
> "every weekday at 7am, give me a brief on the top 3 tech-stock movers"
# Check cron jobs:
hermes cron list
```

See `05-extending.md` for the cron setup.

## Keyboard tips

- **`Alt+Enter`**, **`Ctrl+J`**, or **`Shift+Enter`** — new line in input
  - `Shift+Enter` only works in terminals supporting the Kitty keyboard
    protocol (iTerm2, Kitty, WezTerm, Ghostty). `Alt+Enter` works everywhere.
- **`Ctrl+C`** — interrupt the agent (it'll switch to your next message)
- Type while the agent is running, press Enter — it interrupts and pivots
