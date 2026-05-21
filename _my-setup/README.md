# Hermes Agent — Personal Setup

Configures the cloned `hermes-agent` repo with sensible defaults for daily dev,
self-learning, and investment-research use cases.

## Quick start

```bash
cd ~/Documents/GitHub/community/hermes-agent
bash _my-setup/install.sh
$EDITOR ~/.hermes/.env         # paste real ANTHROPIC_API_KEY
hermes doctor --fix            # auto-fix any leftovers
hermes                         # start chatting
```

That's it for the happy path. The numbered docs below explain everything else.

## Folder layout

```
_my-setup/
├── README.md                       ← you are here
├── install.sh                      ← idempotent installer (run this)
├── templates/
│   ├── env.template                ← copied to ~/.hermes/.env
│   └── config.yaml.template        ← copied to ~/.hermes/config.yaml
└── docs/
    ├── 01-installation.md          ← detailed install steps + prerequisites
    ├── 02-configuration.md         ← what each setting does, how to change it
    ├── 03-daily-usage.md           ← commands, switching providers, Ollama
    ├── 04-troubleshooting.md       ← every `hermes doctor` warning explained
    └── 05-extending.md             ← search APIs, gateway, scheduled jobs
```

**Rule of thumb:** edit files in `templates/` and re-run `install.sh`. Never
edit `~/.hermes/` directly unless tweaking ephemerally — those changes aren't
versioned with the repo.

## What this setup gives you

- **Primary:** Anthropic API (Claude Sonnet 4.6) — your default model
- **Auto-failover:** OpenRouter (when you add a key) — kicks in on rate limits
- **Local LLM:** Ollama pre-wired — switch with `/model custom:ollama:...`
- **Memory + skills enabled** — Hermes learns your projects across sessions
- **Auxiliary models pinned to "main"** — fixes the silent-failure gotcha

## Which doc to read next

| If you want to... | Read |
|---|---|
| Install for the first time | [`docs/01-installation.md`](docs/01-installation.md) |
| Understand or change settings | [`docs/02-configuration.md`](docs/02-configuration.md) |
| Use it daily (commands, switching models) | [`docs/03-daily-usage.md`](docs/03-daily-usage.md) |
| Fix a `hermes doctor` warning | [`docs/04-troubleshooting.md`](docs/04-troubleshooting.md) |
| Add search/gateway/cron/etc. | [`docs/05-extending.md`](docs/05-extending.md) |

## Quick reference card

```
INSTALL          bash _my-setup/install.sh
START            hermes
HEALTH CHECK     hermes doctor
AUTO-FIX         hermes doctor --fix
SWITCH MODEL     /model <id>          (in chat, one-shot)
SWITCH PROVIDER  hermes model         (CLI, persists)
SEE MEMORY       /memory              (in chat)
SEE SKILLS       /skills              (in chat)
UPDATE           git pull && bash _my-setup/install.sh
EDIT SECRETS     $EDITOR ~/.hermes/.env
EDIT SETTINGS    $EDITOR ~/.hermes/config.yaml
```
