## Why

The `tools.allow` in `config/openclaw.json` is set to `["group:ui"]`, which only permits `browser` and `canvas` tools. Per OpenClaw docs (https://docs.openclaw.ai/tools), `group:ui` expands to `browser, canvas` only. This means `exec`, `web_search`, and `web_fetch` are blocked by tool policy — the agent literally cannot call them. When the agent says "thiếu quyền tool", it's actually correct at the runtime level, even though the previous change (`fix-msc-tool-confusion`) told it to never say that.

The fix: add `group:runtime` (exec, bash, process) and `group:web` (web_search, web_fetch) to the allowlist.

## What Changes

- Fix `tools.allow` in `config/openclaw.json`: change from `["group:ui"]` to `["group:ui", "group:runtime", "group:web"]`
- Update `workspace/skills/msc-checker/SKILL.md` anti-pattern section to clarify the difference between "tool not in allowlist" (config issue) vs "tool doesn't exist" (never happens for built-in tools)

## Capabilities

### New Capabilities

- `tool-policy-fix`: Correct the tool allowlist to include runtime and web tool groups alongside UI tools

### Modified Capabilities

_(none — no existing specs to modify)_

## Impact

- `config/openclaw.json` — `tools.allow` array expanded
- `workspace/skills/msc-checker/SKILL.md` — anti-pattern section refined
- No code changes, no API changes
- After applying: agent will have `exec`, `web_search`, `web_fetch` available at runtime

