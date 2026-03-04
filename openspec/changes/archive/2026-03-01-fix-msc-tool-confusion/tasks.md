## 1. MSC Checker Skill Update

- [x] 1.1 Add "Tools Available" section to `workspace/skills/msc-checker/SKILL.md` — insert after Context section, before "Loại thông báo". List built-in OpenClaw tools the agent always has: `exec` (docs: https://docs.openclaw.ai/tools/exec), `web_search` and `web_fetch` (docs: https://docs.openclaw.ai/tools/web). Note: `exec` runs shell commands directly (sandboxing off by default), `web_search` searches via Brave/Perplexity/Gemini, `web_fetch` does HTTP GET + readable extraction.
- [x] 1.2 Add "KHÔNG ĐƯỢC LÀM" (anti-pattern) section to `workspace/skills/msc-checker/SKILL.md` — insert after Tools Available. Explicitly forbid: claiming missing permissions, suggesting browser enablement, asking user to run curl manually. ← (verify: SKILL.md contains both new sections, anti-patterns are clear and unambiguous)

## 2. Knowledge & Tools Docs

- [x] 2.1 Add tool availability note to `workspace/knowledge/muasamcong-guide.md` — insert in the "API trực tiếp" section, clarifying `exec` tool (https://docs.openclaw.ai/tools/exec) is always available for running curl/shell commands, and `web_fetch` (https://docs.openclaw.ai/tools/web) can also fetch API endpoints directly
- [x] 2.2 Add OpenClaw environment tools section to `workspace/TOOLS.md` — list the 3 built-in tools with correct names and doc links: `exec` (https://docs.openclaw.ai/tools/exec), `web_search` + `web_fetch` (https://docs.openclaw.ai/tools/web). Include key params: exec takes `command`, web_search takes `query`, web_fetch takes `url`. ← (verify: all 3 files updated, no references to browser or missing permissions anywhere in the updated content)

