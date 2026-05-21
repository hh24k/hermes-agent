# 05 — Extending Hermes

Mapped to your stated goals: **daily dev, self-learning, self-dev, investment**.

## For daily dev work

### Better code search

Already enabled — `ripgrep` is installed and Hermes uses it automatically.
Make sure your terminal cwd is the project root when you start chatting.

### Browser automation

```bash
cd ~/Documents/GitHub/community/hermes-agent
npm install
```

Now Hermes can drive a real Chrome to inspect docs, test web apps, scrape
pages. Use the `browser` tool — Hermes calls it automatically when relevant.

### GitHub integration (lift rate limits, browse repos)

Add to `~/.hermes/.env`:

```
GITHUB_TOKEN=ghp_...
```

Generate a **classic token with no scopes** at
<https://github.com/settings/tokens/new>. No permissions needed — you just want
the higher API rate limit.

## For self-learning

### High-quality search (pick one)

| Provider | Best for | Get key |
|---|---|---|
| **EXA** | Research, papers, semantic search | <https://exa.ai> |
| **Tavily** | General queries (free tier) | <https://tavily.com> |
| **Firecrawl** | Reading full sites cleanly | <https://firecrawl.dev> |

Add the chosen key to `~/.hermes/.env`:

```
EXA_API_KEY=...
```

Then in chat the `web` tool gets much better. For learning, I'd start with EXA
— it understands research-flavored queries best.

### Use memory deliberately

Memory is what makes Hermes better than plain Claude for long-running learning
projects. Tell it explicitly what to remember:

```
> "remember that I'm learning Rust, currently on chapter 13 of the book,
   weak on lifetimes in async contexts."
```

Periodically review:

```
> /memory
```

Or directly:

```bash
$EDITOR ~/.hermes/memories/MEMORY.md
$EDITOR ~/.hermes/memories/USER.md
```

### Browse community skills

```bash
hermes skills list
hermes skills search learning
hermes skills search study
```

## For self-dev (life automation, scheduled jobs)

### Cron jobs in natural language

Hermes has a built-in `cronjob` tool. Just describe what you want:

```
> "every weekday at 7am, summarize the top 5 hacker news stories
   in 2 sentences each, and write them to ~/Documents/hn-brief.md"
```

Hermes will set up the cron and confirm. List/edit:

```bash
hermes cron list
hermes cron remove <id>
```

Jobs live in `~/.hermes/cron/`. They run when your Mac is awake — not while
asleep. If you want truly always-on automation, run Hermes on a tiny VPS.

### Messaging gateway (chat from your phone)

```bash
hermes gateway setup       # interactive: Telegram | Discord | Slack | Signal | WhatsApp
hermes gateway             # start the service (run in tmux / screen / launchd)
```

Telegram is the easiest: BotFather gives you a token in 30 seconds, no review
process. Once running, you message your bot like a contact and the same Hermes
brain replies.

To keep the gateway running after closing your terminal, the simplest path on
macOS is `tmux`:

```bash
brew install tmux
tmux new -s hermes-gw
hermes gateway
# detach with Ctrl-b then d
# reattach with: tmux attach -t hermes-gw
```

A `launchd` plist for proper background-service behavior is a more permanent
option — search "macOS launchd LaunchAgent" for the standard recipe.

## For investment

### The right tool combination

For real investment-research workflows you want:

1. **EXA** — `EXA_API_KEY` — for finding recent analysis, SEC filings, papers
2. **Firecrawl** — `FIRECRAWL_API_KEY` — for cleanly scraping company sites, PRs, IR pages
3. **Browser tool** — `npm install` — for sites that require JS rendering
4. **(Optional) Cron** — for scheduled morning briefings

Add the first two to `~/.hermes/.env`:

```
EXA_API_KEY=...
FIRECRAWL_API_KEY=...
```

### Sample workflow

```
> "pull the latest 10-Q for $NVDA, summarize risk factors,
   and tell me what's new vs last quarter"

> "every weekday at 6:45am pacific, give me a brief on
   pre-market movement for AAPL, MSFT, NVDA, and any
   tech news that might explain it. write to ~/Documents/morning-brief.md"
```

### What to NOT do

Don't connect Hermes to a brokerage account or anything with trade-execution
authority. It's an LLM agent — confident-sounding but capable of being
catastrophically wrong. Use it for research and synthesis, not for pulling
triggers. (This is true of every LLM agent.)

## Mixture-of-Agents (MoA) — when you need a second opinion

Once you add `OPENROUTER_API_KEY`, the `moa` tool unlocks. Hermes can ask
multiple models the same question and synthesize. Useful for:

- High-stakes decisions where you want diverse takes
- Self-learning when the explanation feels off and you want a sanity check
- Investment analysis where confirmation bias is dangerous

In chat:

```
> "use moa to compare 3 takes on whether SaaS gross margins ~80% are
   sustainable post-AI."
```

## Custom skills — make Hermes specifically yours

The agent can write skills, but you can too. Drop a Markdown file in
`~/.hermes/skills/` describing a workflow:

```markdown
# my-pr-review

## When to use
When I ask for a PR review.

## Process
1. Run `git diff main...HEAD --stat` to get the scope.
2. Read the description from `gh pr view --json body`.
3. Look at every changed test file first — no tests means push back.
4. For each non-test file, check: types, error handling, security.
5. Output a markdown checklist with severity ratings.
```

Hermes will auto-load it when the trigger matches your prompt.

## What to enable next, in priority order

Given your goals, here's the path I'd take:

1. **Now:** `hermes doctor --fix`, `npm install`, `hermes skills list`,
   add `GITHUB_TOKEN`
2. **This week:** Add `OPENROUTER_API_KEY` (failover + MoA) and `EXA_API_KEY`
   (research quality)
3. **When you want phone access:** `hermes gateway setup` with Telegram
4. **When you have a cheap VPS:** Move the gateway + cron there so it runs 24/7
5. **Later:** `FIRECRAWL_API_KEY` if you're doing serious investment research
