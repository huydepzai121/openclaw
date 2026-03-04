## Context

The `config/openclaw.json` has `tools.allow: ["group:ui"]`. Per OpenClaw docs (https://docs.openclaw.ai/tools):

- `group:ui` = `browser, canvas`
- `group:runtime` = `exec, bash, process`
- `group:web` = `web_search, web_fetch`

The current allowlist only permits UI tools. The agent cannot call `exec`, `web_search`, or `web_fetch` — they are blocked at the tool policy level before the model even sees them. This is why the msc-checker skill fails: the agent literally does not have the tools available.

## Goals / Non-Goals

**Goals:**
- Add `group:runtime` and `group:web` to `tools.allow` so the agent has `exec`, `web_search`, `web_fetch`
- Update SKILL.md anti-pattern to distinguish config-level blocks from non-existent tools

**Non-Goals:**
- Not changing sandbox mode (already `off`)
- Not adding other tool groups (fs, sessions, memory, etc.)
- Not changing per-agent tool overrides

## Decisions

1. **Add groups, not individual tools** — Using `group:runtime` and `group:web` instead of listing `exec`, `web_search`, `web_fetch` individually. This follows OpenClaw convention and automatically includes related tools (`bash`, `process`).

2. **Keep `group:ui` in the allowlist** — Browser and canvas may be needed for other skills. No reason to remove them.

3. **Update anti-pattern section** — Add a note about checking `tools.allow` in config if tools are genuinely unavailable, so the agent can self-diagnose.

## Risks / Trade-offs

- **[Low risk] Broader tool surface** — Adding `group:runtime` gives the agent `exec` + `bash` + `process`. This is intentional — the agent needs shell access for API calls and background tasks. Sandbox mode is already `off`.
- **[No risk] Web tools** — `web_search` and `web_fetch` are read-only tools with no destructive capability.

