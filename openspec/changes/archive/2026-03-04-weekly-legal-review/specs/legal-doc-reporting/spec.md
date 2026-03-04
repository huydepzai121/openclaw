## ADDED Requirements

### Requirement: Agent SHALL produce a formatted Telegram report
The agent SHALL generate a Telegram message summarizing all new legal documents found during the weekly review, formatted for readability.

#### Scenario: Report with documents found
- **WHEN** the weekly review discovers new legal documents
- **THEN** the agent SHALL send a Telegram message with: header (title + date + source info), documents grouped by type (Luật, Nghị định, Thông tư, Quyết định, Nghị quyết), each entry showing document number, issuing authority, date, domain tag, and 1-2 sentence summary

#### Scenario: Report with no new documents
- **WHEN** the weekly review finds no new documents in the past 7 days
- **THEN** the agent SHALL send a brief message: "Không có văn bản pháp luật mới trong tuần qua."

#### Scenario: Report includes source links
- **WHEN** generating the report
- **THEN** each document entry SHALL include a link to the full text on the source website (preferring vbpl.vn links)

### Requirement: Agent SHALL group documents by type in the report
The agent SHALL organize the report by document type in hierarchy order.

#### Scenario: Document type ordering
- **WHEN** the report contains multiple document types
- **THEN** they SHALL appear in this order: Luật/Bộ luật → Nghị quyết QH → Nghị định → Quyết định TTg → Thông tư → Thông tư liên tịch

#### Scenario: Empty type sections are omitted
- **WHEN** a document type has no new documents this week
- **THEN** that section SHALL be omitted from the report (not shown as empty)

### Requirement: Agent SHALL tag documents with domain emoji
The agent SHALL prefix each document entry with a domain-specific emoji for quick visual scanning.

#### Scenario: Domain emoji mapping
- **WHEN** a document is tagged with a domain
- **THEN** the agent SHALL use the corresponding emoji: 🏗️ Đấu thầu/Đầu tư công, 💰 Thuế/Tài chính, 🏢 Doanh nghiệp/Đầu tư, 👷 Lao động/BHXH, 🏠 BĐS/Xây dựng, 📈 Chứng khoán/Ngân hàng, 💻 CNTT/An ninh mạng, 🌍 Thương mại QT/Hải quan, 📋 Khác

### Requirement: Agent SHALL save results to memory
The agent SHALL persist the weekly review results to a memory file for deduplication and continuity.

#### Scenario: Memory file creation
- **WHEN** the weekly review completes
- **THEN** the agent SHALL write results to `workspace/memory/vbpl-YYYY-MM-DD.md` with: date, source list, document count, and full document list with metadata

#### Scenario: Memory file already exists for today
- **WHEN** a memory file for today's date already exists (e.g., manual re-run)
- **THEN** the agent SHALL append a new section with timestamp rather than overwriting

### Requirement: Agent SHALL highlight documents taking effect soon
The agent SHALL flag documents that will take effect within the next 30 days.

#### Scenario: Document with upcoming effective date
- **WHEN** a document has an effective date (ngày có hiệu lực) within 30 days from the report date
- **THEN** the agent SHALL add a "⏰ Có hiệu lực: DD/MM/YYYY" annotation to the entry

#### Scenario: Effective date not available
- **WHEN** the effective date cannot be determined from available information
- **THEN** the agent SHALL omit the effective date annotation (no placeholder)

### Requirement: Agent SHALL provide a weekly summary count
The agent SHALL include aggregate statistics at the end of the report.

#### Scenario: Summary statistics
- **WHEN** the report is generated
- **THEN** it SHALL end with a summary line showing: total document count, breakdown by type, and count of documents taking effect within 30 days

