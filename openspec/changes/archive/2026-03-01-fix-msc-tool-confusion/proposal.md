## Why

The OpenClaw agent incorrectly tells users it "lacks tool permissions" to call APIs via `exec` (https://docs.openclaw.ai/tools/exec), and suggests enabling `browser.enabled=true` — which doesn't exist anymore. The root cause: the skill and knowledge files don't explicitly state that the agent HAS the built-in tools (`exec`, `web_search`, `web_fetch`) available by default. The agent infers (wrongly) that it needs special permissions.

## What Changes

- Add a clear "Available Tools" section to `workspace/skills/msc-checker/SKILL.md` stating the agent has these built-in OpenClaw tools available — no special config needed:
  - `exec` (key param: `command`) — run shell commands, sandboxing off by default (docs: https://docs.openclaw.ai/tools/exec)
  - `web_search` (key param: `query`) — search web via Brave/Perplexity/Gemini (docs: https://docs.openclaw.ai/tools/web)
  - `web_fetch` (key param: `url`) — HTTP GET + readable extraction (docs: https://docs.openclaw.ai/tools/web)
- Add a similar clarification to `workspace/knowledge/muasamcong-guide.md`
- Add a "NEVER say" anti-pattern section to the skill to prevent the agent from claiming it can't run curl or suggesting browser enablement
- Update `workspace/TOOLS.md` with the built-in tools list, key params, and doc links

## Capabilities

### New Capabilities

_(none — documentation/prompt fix only)_

### Modified Capabilities

_(none)_

## Impact

- `workspace/skills/msc-checker/SKILL.md` — added tool availability section (exec, web_search, web_fetch with key params + doc links) + anti-pattern guard
- `workspace/knowledge/muasamcong-guide.md` — added tool availability note with doc links
- `workspace/TOOLS.md` — added OpenClaw built-in tools section with key params + doc links
- No runtime/config changes

