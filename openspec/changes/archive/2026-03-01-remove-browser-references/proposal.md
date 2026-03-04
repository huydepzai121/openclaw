## Why

The project does not use any browser/headless browser functionality — all web interactions are done via `exec curl` and `web_search`/`web_fetch`. However, multiple files still reference "browser", "Chromium", "Playwright", and "headless" in config and documentation. These references are misleading and add noise. Removing them keeps the project clean and avoids confusion about capabilities.

## What Changes

- Remove the `"browser"` config block from `config/openclaw.json`
- Remove browser-related mentions from `SETUP.md` (section title "cho trang không cần browser", references to "browser headless", "Chromium/Playwright")
- Remove browser-related mentions from `workspace/knowledge/muasamcong-guide.md` ("Tại sao dùng API thay browser?", "không cần browser headless")
- Remove browser-related mentions from `workspace/skills/msc-checker/SKILL.md` ("không cần browser")

## Capabilities

### New Capabilities

_(none — this is a cleanup change, no new capabilities)_

### Modified Capabilities

_(none — no spec-level behavior changes, only removing dead references)_

## Impact

- `config/openclaw.json` — `browser` key removed
- `SETUP.md` — section 9 title and body text cleaned up
- `workspace/knowledge/muasamcong-guide.md` — section header and body text cleaned up
- `workspace/skills/msc-checker/SKILL.md` — context line cleaned up
- No runtime behavior changes — browser was already `enabled: false` and unused

