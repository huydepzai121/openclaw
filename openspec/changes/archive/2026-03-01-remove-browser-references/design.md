## Context

OpenClaw is a Telegram news bot running in Docker. The project never uses Sao /headless browser functionality — all web interactions use `exec curl`, `web_search`, and `web_fetch`. However, several files still reference "browser", "Chromium", "Playwright", and "headless":

- `config/openclaw.json` has a `"browser": { "enabled": false }` block
- `SETUP.md` section 9 title says "cho trang không cần browser" and body mentions "browser headless", "Chromium/Playwright"
- `workspace/knowledge/muasamcong-guide.md` has a section "Tại sao dùng API thay browser?" and mentions "browser headless"
- `workspace/skills/msc-checker/SKILL.md` mentions "không cần browser, không cần MCP server"

## Goals / Non-Goals

**Goals:**
- Remove the `browser` config block from `config/openclaw.json`
- Clean up all browser-related text from documentation files (`SETUP.md`, `muasamcong-guide.md`, `msc-checker/SKILL.md`)
- Keep the meaning of each section intact — just remove the browser noise

**Non-Goals:**
- No runtime behavior changes
- No restructuring of documentation beyond removing browser mentions
- Not touching any code files (there are none with browser references)

## Decisions

1. **Remove `browser` block entirely from config** — It's `enabled: false` and unused. Removing it is cleaner than leaving a dead config block.

2. **Rewrite affected text rather than just deleting lines** — Some sentences mention browser as a contrast ("không cần browser"). These should be reworded to stand on their own without the browser comparison, rather than leaving awkward gaps.

3. **Keep section structure intact** — For example, SETUP.md Bước 9 keeps its section but with a cleaner title. The muasamcong-guide keeps its API section but without the "vs browser" framing.

## Risks / Trade-offs

- **[Low risk] Config key removal** — If any OpenClaw runtime reads `browser.enabled` and fails on missing key, this could cause issues. Mitigation: the key is already `false`, and the Dockerfile installs no browser. The runtime should handle missing config gracefully.
- **[Minimal risk] Documentation rewording** — Changing wording could lose some context for readers who wonder "why curl instead of browser?" Mitigation: the reworded text still explains the API-first approach clearly.
