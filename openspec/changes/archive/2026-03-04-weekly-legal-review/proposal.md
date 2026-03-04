## Why

The "Thời Sự Huy" agent currently covers general news and MSC (mua sắm công) notifications, but has no automated way to track new legal documents (văn bản pháp luật) published weekly. Vietnamese legal documents — laws, decrees, circulars — change frequently and affect many domains the user cares about (procurement, tax, real estate, labor, IT). A weekly legal review skill would keep the user informed of important new regulations without manual checking across multiple government portals.

## What Changes

- Add a new skill `vbpl-reviewer` under `workspace/skills/vbpl-reviewer/SKILL.md` that defines the SOP for weekly legal document review
- The skill uses `web_search` and `web_fetch` to scan multiple authoritative sources (vbpl.vn, vanban.chinhphu.vn, congbao.chinhphu.vn, thuvienphapluat.vn)
- Results are categorized by document type (Luật, Nghị định, Thông tư, Quyết định) and domain (tax, labor, procurement, etc.)
- Output is a formatted Telegram report highlighting key new documents with number, issuing authority, date, and summary
- Results are saved to `workspace/memory/vbpl-YYYY-MM-DD.md` for continuity
- Update `workspace/knowledge/phapluat-sources.md` with skill-specific search strategies and domain keywords

## Capabilities

### New Capabilities
- `legal-doc-scanning`: Defines how the agent discovers new legal documents from multiple government sources using web_search and web_fetch, including search strategies, source priority, and deduplication
- `legal-doc-reporting`: Defines the Telegram output format, categorization rules, domain tagging, and memory storage for weekly legal review results

### Modified Capabilities

## Impact

- New files: `workspace/skills/vbpl-reviewer/SKILL.md`
- Modified files: `workspace/knowledge/phapluat-sources.md` (add domain keywords and search patterns used by the skill)
- Cron: A new weekly cron job will need to be added to trigger the skill (user to configure timing)
- No code changes — workspace-as-code only
- Dependencies: Relies on `web_search` and `web_fetch` tools (already in allowlist via `group:web`)

