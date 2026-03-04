## ADDED Requirements

### Requirement: Agent classifies MSC notifications by content type
After fetching notifications from the MSC API, the agent SHALL classify each notification into one of three categories:
- **Maintenance**: notiType=3, OR title matches keywords `bảo trì|ngừng hoạt động|tạm ngưng|downtime|nâng cấp hệ thống`
- **Process change**: notiType=2 AND title matches keywords `quy trình|thay đổi|cập nhật|sửa đổi|quy định mới`
- **Informational**: all other notifications (no action, report only)

#### Scenario: Maintenance notification classified correctly
- **WHEN** the MSC API returns a notification with notiType=3
- **THEN** the agent SHALL classify it as "maintenance"

#### Scenario: Process change notification classified correctly
- **WHEN** the MSC API returns a notification with notiType=2 AND title contains "thay đổi quy trình"
- **THEN** the agent SHALL classify it as "process change"

#### Scenario: Generic system notification not misclassified
- **WHEN** the MSC API returns a notification with notiType=2 AND title does NOT contain any process change keywords
- **THEN** the agent SHALL classify it as "informational" and take no automated action

### Requirement: Agent auto-updates HEARTBEAT.md on maintenance detection
When a maintenance notification is detected, the agent SHALL automatically add a structured maintenance pause block to `workspace/HEARTBEAT.md` without asking the user for confirmation.

The block SHALL follow this format:
```
## MSC Maintenance Pause
- Status: active
- Start: <ISO 8601 datetime with timezone>
- End: <ISO 8601 datetime with timezone>
- Source: MSC notification <commonNotificationId>
- Action: Skip msc-checker until End time, then remove this block
```

If start/end times cannot be parsed from the notification content, the agent SHALL use the notification's `startDate` as Start and default to Start + 8 hours as End.

#### Scenario: Maintenance notification triggers HEARTBEAT update
- **WHEN** the agent detects a maintenance notification with title "Bảo trì hệ thống từ 22:00 05/03 đến 06:00 06/03"
- **THEN** the agent SHALL append the maintenance pause block to HEARTBEAT.md with Start=2026-03-05T22:00+07:00 and End=2026-03-06T06:00+07:00

#### Scenario: Maintenance without explicit times uses defaults
- **WHEN** the agent detects a maintenance notification that does not contain parseable start/end times
- **THEN** the agent SHALL use the notification's startDate as Start and Start + 8 hours as End

#### Scenario: Duplicate maintenance not added twice
- **WHEN** the agent detects a maintenance notification whose commonNotificationId already exists in a HEARTBEAT.md maintenance block
- **THEN** the agent SHALL NOT add a duplicate block

### Requirement: Agent auto-cleans HEARTBEAT.md after maintenance ends
On each heartbeat or MSC check, the agent SHALL check if any maintenance pause block in HEARTBEAT.md has an End time in the past. If so, the agent SHALL remove that block and notify the user.

#### Scenario: Maintenance window has passed
- **WHEN** the agent runs a heartbeat or MSC check AND current time is after the End time of a maintenance pause block
- **THEN** the agent SHALL remove the maintenance pause block from HEARTBEAT.md and include a note in the Telegram report: "Bảo trì MSC đã kết thúc, đã resume check tự động"

#### Scenario: Maintenance still active
- **WHEN** the agent runs a heartbeat or MSC check AND current time is before the End time of a maintenance pause block
- **THEN** the agent SHALL skip the MSC API check and report "MSC đang bảo trì, bỏ qua check lần này"

### Requirement: Agent asks user before updating knowledge guide on process changes
When a process change notification is detected, the agent SHALL NOT automatically update `workspace/knowledge/muasamcong-guide.md`. Instead, the agent SHALL present the proposed changes to the user via Telegram and wait for confirmation.

#### Scenario: Process change detected — user is asked
- **WHEN** the agent detects a process change notification
- **THEN** the agent SHALL send a Telegram message summarizing the change and asking: "Phát hiện thay đổi quy trình: <summary>. Cập nhật muasamcong-guide.md không? (yes/no)"

#### Scenario: User confirms — guide is updated
- **WHEN** the user replies "yes" (or equivalent affirmative) to the process change prompt
- **THEN** the agent SHALL update the relevant section in `workspace/knowledge/muasamcong-guide.md` with the new process information, including a date annotation

#### Scenario: User declines — no update
- **WHEN** the user replies "no" (or equivalent negative) to the process change prompt
- **THEN** the agent SHALL NOT modify muasamcong-guide.md and SHALL log the skipped update in the daily memory file

### Requirement: Telegram report includes automated actions section
The Telegram report output SHALL include a `🤖 Hành động tự động` section at the bottom, listing all automated actions taken or proposed during this check.

#### Scenario: Report with auto-action taken
- **WHEN** the agent has auto-updated HEARTBEAT.md due to maintenance
- **THEN** the Telegram report SHALL include: "🤖 **Hành động tự động:**\n- ✅ Đã cập nhật HEARTBEAT.md — tạm dừng check MSC từ <Start> đến <End>"

#### Scenario: Report with proposed action
- **WHEN** the agent has detected a process change and is asking user
- **THEN** the Telegram report SHALL include: "🤖 **Hành động đề xuất:**\n- ❓ Phát hiện thay đổi quy trình, chờ xác nhận cập nhật guide"

#### Scenario: Report with no actions
- **WHEN** no maintenance or process change notifications are detected
- **THEN** the Telegram report SHALL NOT include the automated actions section

