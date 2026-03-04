## ADDED Requirements

### Requirement: Agent SHALL discover new legal documents via web_search
The agent SHALL use `web_search` with site-scoped queries to discover legal documents published within the last 7 days from authoritative Vietnamese government sources.

#### Scenario: Weekly search across primary sources
- **WHEN** the skill is triggered (via cron or manual request)
- **THEN** the agent SHALL execute web_search queries targeting at least these sources: vbpl.vn, vanban.chinhphu.vn, congbao.chinhphu.vn, thuvienphapluat.vn

#### Scenario: Search queries cover document types
- **WHEN** searching for new documents
- **THEN** the agent SHALL use separate queries for major document types: Luật, Nghị định, Thông tư, Quyết định of Thủ tướng, and Nghị quyết

#### Scenario: Brave Search returns 429 rate limit
- **WHEN** web_search returns a 429 error
- **THEN** the agent SHALL wait 2 seconds and retry, up to 3 retries per query

### Requirement: Agent SHALL extract document metadata from search results
The agent SHALL parse search result snippets and titles to extract structured metadata for each discovered document.

#### Scenario: Successful metadata extraction
- **WHEN** a search result contains a legal document reference
- **THEN** the agent SHALL extract: document number (số hiệu), document type (loại văn bản), issuing authority (cơ quan ban hành), issue date (ngày ban hành), and summary (trích yếu)

#### Scenario: Document number format recognition
- **WHEN** parsing search results
- **THEN** the agent SHALL recognize standard Vietnamese document number formats including: `XX/YYYY/NĐ-CP`, `XX/YYYY/QH15`, `XX/YYYY/TT-BXX`, `XX/YYYY/QĐ-TTg`, and `XX/YYYY/NQ-CP`

### Requirement: Agent SHALL use web_fetch for detail pages when needed
The agent SHALL use `web_fetch` to retrieve full document detail pages when search snippets lack sufficient information.

#### Scenario: Fetching document detail from vbpl.vn
- **WHEN** a search result links to a vbpl.vn detail page (URL pattern: `vbpl.vn/.../vbpq-toanvan.aspx?ItemID=...`)
- **THEN** the agent SHALL use `web_fetch` to retrieve the page and extract the full trích yếu and effective date (ngày có hiệu lực)

#### Scenario: web_fetch fails on a detail page
- **WHEN** web_fetch returns an error or empty content for a detail page
- **THEN** the agent SHALL use the information already available from the search snippet and note the incomplete data

### Requirement: Agent SHALL deduplicate documents across sources
The agent SHALL deduplicate discovered documents to avoid reporting the same document multiple times.

#### Scenario: Same document found on multiple sources
- **WHEN** the same document number (số hiệu) appears in results from different sources
- **THEN** the agent SHALL merge them into a single entry, preferring metadata from the higher-priority source (vbpl.vn > vanban.chinhphu.vn > congbao.chinhphu.vn > thuvienphapluat.vn)

#### Scenario: Deduplication against previous weeks
- **WHEN** a document was already reported in a previous weekly review (stored in memory files)
- **THEN** the agent SHALL exclude it from the current report unless it has new information (e.g., effective date announced)

### Requirement: Agent SHALL categorize documents by domain
The agent SHALL assign each document to one or more domains based on keyword matching in the document title and summary.

#### Scenario: Domain assignment by keywords
- **WHEN** a document's title or summary contains domain keywords (e.g., "đấu thầu" → Procurement, "thuế" → Tax)
- **THEN** the agent SHALL tag the document with the matching domain(s)

#### Scenario: Document matches no domain keywords
- **WHEN** a document does not match any predefined domain keywords
- **THEN** the agent SHALL categorize it as "Khác" (Other)

### Requirement: Agent SHALL scope to central government documents only
The agent SHALL focus on documents issued by central government bodies (Trung ương) and exclude provincial/local documents.

#### Scenario: Filtering out local documents
- **WHEN** a document is issued by a provincial UBND or local authority
- **THEN** the agent SHALL exclude it from the report

