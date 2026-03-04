# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

OpenClaw is a configuration-only AI agent workspace — there is no application source code to build, lint, or test. The repo defines an OpenClaw gateway instance that runs inside a Docker container ("God Mode"), connecting an AI agent to Telegram (primary), Zalo, and Slack channels. The current agent persona is "Thời Sự Huy" — a Vietnamese news curator bot that aggregates and delivers news 3x daily via Telegram.

All "code" in this repo is markdown files (agent personality, knowledge bases, skills) and configuration (JSON, YAML, Docker). The agent reads `workspace/` files at session start to shape its behavior — editing these files IS the development workflow.

## Commands

```bash
# Start/restart the container
docker compose up -d
docker compose down && docker compose up -d

# Rebuild after Dockerfile changes
docker compose up -d --build

# View logs
docker compose logs -f

# Shell into container
docker compose exec openclaw bash

# Pairing (after bot sends code in Telegram)
docker compose exec openclaw openclaw pairing approve telegram <CODE>

# Cron management
docker compose exec openclaw openclaw cron list
docker compose exec openclaw openclaw cron add --name "..." --cron "..." --tz "Asia/Ho_Chi_Minh" --session isolated --message "..." --announce --channel telegram --to "<CHAT_ID>"
docker compose exec openclaw openclaw cron remove <ID>

# Sub-agents
docker compose exec openclaw openclaw subagents list
docker compose exec openclaw openclaw subagents spawn msc "Kiểm tra MSC"
```

There is no build step, no linter, no test suite. Changes to workspace files take effect on the agent's next session (no container restart needed).

## Architecture

```
openclaw/
├── config/openclaw.json       # Gateway config: model provider, channels, tools, sub-agents
├── docker-compose.yml         # Single "godmode" container definition
├── Dockerfile.godmode         # Full dev environment (Node 22, Python, Go, Rust, Java, Docker CLI)
├── .env / .env.example        # Secrets: API keys, bot tokens, chat IDs
├── setup.sh                   # First-time setup script
├── workspace/                 # Agent workspace — mounted into container at ~/.openclaw/workspace
│   ├── SOUL.md                # Agent personality and behavioral rules
│   ├── IDENTITY.md            # Agent name, role, emoji
│   ├── USER.md                # User info (name, language, timezone, preferences)
│   ├── AGENTS.md              # Session lifecycle rules, memory protocol, safety boundaries
│   ├── TOOLS.md               # Environment-specific tool notes (camera names, SSH hosts, etc.)
│   ├── HEARTBEAT.md           # Periodic task checklist (empty = skip heartbeat)
│   ├── BOOTSTRAP.md           # First-run onboarding script (delete after setup)
│   ├── knowledge/             # Domain knowledge files the agent reads for context
│   └── skills/                # Skill definitions (each skill = folder with SKILL.md)
│       └── msc-checker/       # Mua sắm công notification checker skill
├── openspec/                  # OpenSpec change tracking (proposal → design → spec → tasks)
│   ├── changes/               # Active and archived changes
│   └── specs/                 # Standalone specs
```

### Key Architectural Concepts

**Workspace-as-code**: The agent's behavior is entirely defined by markdown files in `workspace/`. There is no runtime code in this repo. The OpenClaw platform (installed via npm in the Docker image) reads these files.

**Session lifecycle** (defined in `AGENTS.md`): Every session, the agent reads SOUL.md → USER.md → recent memory files. Memory is split into daily logs (`memory/YYYY-MM-DD.md`) and curated long-term memory (`MEMORY.md`, main session only).

**Skills**: A skill is a folder under `workspace/skills/` containing a `SKILL.md` file. Skills are SOPs — step-by-step instructions the agent follows for specific tasks. The agent reads the relevant SKILL.md when triggered.

**OpenSpec workflow**: Changes are tracked in `openspec/changes/` using a structured flow: proposal.md → design.md → spec.md → tasks.md. Completed changes move to `archive/`. Each change has an `.openspec.yaml` metadata file.

## Special Patterns and Non-Obvious Details

### Config passthrough via /tmp
The `docker-compose.yml` mounts `config/openclaw.json` to `/tmp/openclaw-config.json:ro`. The container entrypoint copies it to `~/.openclaw/openclaw.json` at startup. This avoids permission issues with direct volume mounts into the OpenClaw data directory.

### Model provider setup
The project uses a custom OpenAI-compatible provider called `myprovider` (not direct Anthropic/OpenAI keys). The `ANTHROPIC_API_KEY not set` warning in logs is expected and harmless. Provider config is in `config/openclaw.json` under `models.providers.myprovider`, with credentials via `MYPROVIDER_BASE_URL` and `MYPROVIDER_API_KEY` env vars.

### Tool allowlist
`config/openclaw.json` has `tools.allow: ["group:ui", "group:runtime", "group:web"]`. The agent always has `exec`, `web_search`, and `web_fetch` built-in. If a built-in tool appears unavailable at runtime, check this allowlist — it must include `group:runtime` and `group:web`.

### Brave Search quirks
- Country code `VN` returns 422 — the agent auto-retries with `ALL`
- Free plan rate limit is 1 req/sec — 429 errors are expected and auto-retried

### MSC Checker skill — API details
The `msc-checker` skill calls `muasamcong.mpi.gov.vn` JSON APIs directly via `exec curl` (POST requests). API response content fields contain HTML that must be stripped before display. The skill has explicit anti-patterns documented: never claim missing tool permissions, never suggest enabling browser, never ask user to run curl manually.

### Cron jobs use isolated sessions
All cron jobs are configured with `--session isolated` — each run gets a fresh agent session with no shared history. The cron message must be self-contained or reference workspace files the agent will read at session start.

### Memory security model
`MEMORY.md` (long-term curated memory) is only loaded in main sessions (direct chat with the user). It is NOT loaded in shared contexts (Discord, group chats) to prevent personal context leakage.

### Language
The user (Huy) communicates in Vietnamese. Workspace files, knowledge bases, and skill definitions are written in Vietnamese. The agent's timezone is `Asia/Ho_Chi_Minh` (UTC+7).

### Zalo plugin requires manual zod install
After installing the Zalo plugin (`openclaw plugins install @openclaw/zalo`), you must manually install zod: `cd /home/claw/.openclaw/extensions/zalo && npm install zod`. This is a known dependency issue.
