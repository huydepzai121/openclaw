## Context

The "Thời Sự Huy" agent runs inside an OpenClaw Docker container, connected to Telegram. It already has an MSC checker skill (`workspace/skills/msc-checker/SKILL.md`) that uses `exec curl` to call JSON APIs. For legal document review, the target sources (vbpl.vn, vanban.chinhphu.vn, congbao.chinhphu.vn) do NOT expose public REST APIs — vbpl.vn uses SharePoint with internal AJAX endpoints, and its WebService API (`ws.vbpl.vn`) requires institutional credentials.

The agent has `web_search` (Brave Search) and `web_fetch` built-in, which are the practical tools for this task. The existing `workspace/knowledge/phapluat-sources.md` already documents source URLs, document hierarchy, and search strategies.

## Goals / Non-Goals

**Goals:**
- Weekly automated scan of new Vietnamese legal documents from authoritative sources
- Categorized Telegram report by document type and domain
- Memory persistence for continuity across sessions
- Deduplication across sources and across weeks

**Non-Goals:**
- Full-text analysis or legal interpretation of documents
- Real-time monitoring (daily or more frequent) — weekly cadence only
- Using ws.vbpl.vn SOAP API (requires institutional credentials)
- Scraping JavaScript-rendered content (web_fetch doesn't run JS)
- Tracking local/provincial documents — focus on central government (Trung ương) only

## Decisions

### D1: Primary data source strategy — web_search + web_fetch combo

**Choice**: Use `web_search` as primary discovery, `web_fetch` for detail extraction.

**Rationale**: vbpl.vn's internal AJAX endpoints (`/VBQPPL_UserControls/Publishing_22/TimKiem/p_KetQuaTimKiemVanBan.aspx`) return HTML fragments that require POST with specific parameters and may break without notice. `web_search` with site-scoped queries is more resilient and covers multiple sources in one pass.

**Alternatives considered**:
- Direct AJAX POST to vbpl.vn internal endpoints — fragile, undocumented, may require session cookies
- ws.vbpl.vn SOAP API — requires credentials we don't have
- RSS feeds — congbao.chinhphu.vn and vbpl.vn don't expose RSS

### D2: Multi-source search with priority

**Choice**: Search across 4 sources in priority order:
1. `vbpl.vn` — CSDL quốc gia, most comprehensive
2. `vanban.chinhphu.vn` — Chính phủ documents
3. `congbao.chinhphu.vn` — Công báo (official gazette)
4. `thuvienphapluat.vn` — Good summaries and analysis

**Rationale**: No single source is complete. vbpl.vn has the widest coverage but poor searchability via web. thuvienphapluat.vn has better SEO and summaries. Cross-referencing improves recall.

### D3: Deduplication by document number (số hiệu)

**Choice**: Deduplicate by extracting and normalizing document numbers (e.g., "Nghị định 24/2024/NĐ-CP"). Store seen document numbers in memory files.

**Rationale**: The same document appears across multiple sources. Document number is the canonical identifier in Vietnamese legal system.

### D4: Domain categorization using keyword matching

**Choice**: Categorize documents into domains using keyword lists in the skill definition, similar to MSC checker's notiType classification.

**Rationale**: Simple, transparent, easy to maintain. The agent can also use its general knowledge to improve categorization beyond keywords.

### D5: Skill file structure — single SKILL.md

**Choice**: One `workspace/skills/vbpl-reviewer/SKILL.md` file containing the full SOP.

**Rationale**: Follows the msc-checker pattern. Skills are self-contained SOPs. No need for multiple files.

## Risks / Trade-offs

- **Brave Search rate limits** → Same mitigation as MSC checker: auto-retry on 429, use country code `ALL` instead of `VN`
- **web_fetch can't render JS** → vbpl.vn's search results load via AJAX (JS). Mitigation: rely on web_search for discovery, use web_fetch only for static detail pages (e.g., `vbpl.vn/.../vbpq-toanvan.aspx?ItemID=...`)
- **Search result quality varies** → Mitigation: use multiple specific queries per domain rather than one broad query; cross-reference across sources
- **Document number extraction from search snippets may be imperfect** → Mitigation: use regex patterns for common formats (Luật số XX/YYYY/QH15, Nghị định XX/YYYY/NĐ-CP, etc.); accept some duplicates rather than miss documents
- **Weekly cadence may miss time-sensitive documents** → Accepted trade-off; user can trigger manually anytime via Telegram

## Open Questions

- Preferred day/time for weekly cron job? (Suggestion: Monday morning 8:00 AM ICT)
- Should the skill also track documents that are about to take effect (sắp có hiệu lực) vs just newly issued?

