## Context

The `msc-checker` skill instructs the OpenClaw agent to call the muasamcong.mpi.gov.vn notification API, parse results, and send a formatted Telegram report. Currently the skill is "read-only" — it fetches and reports but never acts on the content.

The workspace has two files that should stay in sync with MSC state:
- `workspace/HEARTBEAT.md` — controls the agent's periodic check behavior
- `workspace/knowledge/muasamcong-guide.md` — reference guide for procurement processes

When MSC announces maintenance, the agent keeps polling during downtime (getting errors). When MSC changes procurement processes, the knowledge guide silently goes stale.

## Goals / Non-Goals

**Goals:**
- Add notification classification logic to the msc-checker skill (maintenance vs process change vs other)
- Auto-update HEARTBEAT.md when maintenance is detected (pause MSC checks during downtime window)
- Ask user confirmation then update muasamcong-guide.md when process changes are detected
- Auto-cleanup HEARTBEAT.md after maintenance window ends
- Always notify user of all automated actions via the Telegram report

**Non-Goals:**
- Not changing the API endpoints, curl commands, or authentication
- Not adding new notification types beyond what MSC already provides
- Not creating a separate skill — this extends the existing msc-checker skill
- Not building a database or persistent state beyond the existing file-based approach

## Decisions

1. **Classification by notiType + keyword matching in title**

   Use notiType as primary signal, title keywords as secondary:
   - Maintenance: `notiType=3` OR title contains `bảo trì|ngừng hoạt động|tạm ngưng|downtime|nâng cấp hệ thống`
   - Process change: `notiType=2` AND title contains `quy trình|thay đổi|cập nhật|sửa đổi|quy định mới`
   - Everything else: report only, no action

   Why: notiType alone isn't reliable enough — notiType=2 covers all system notifications, not just process changes. Keyword matching narrows it down.

2. **Two-tier action model: auto vs ask-first**

   - Maintenance → auto-update HEARTBEAT.md + notify user (low risk, time-sensitive)
   - Process change → present diff to user in Telegram, wait for confirmation before updating guide (high risk, needs human review)

   Why: Maintenance pauses are temporary and reversible. Knowledge guide changes are permanent and could be wrong if the agent misinterprets the notification.

3. **HEARTBEAT.md format for maintenance entries**

   Add a structured block that the agent can parse on subsequent heartbeats:

   ```markdown
   ## MSC Maintenance Pause
   - Status: active
   - Start: 2026-03-05T22:00+07:00
   - End: 2026-03-06T06:00+07:00
   - Source: MSC notification <UUID>
   - Action: Skip msc-checker until End time, then remove this block
   ```

   Why: Structured format lets the agent reliably detect and clean up the entry. Using ISO timestamps avoids ambiguity.

4. **Cleanup via next heartbeat/check, not a timer**

   The agent checks if maintenance has ended on each heartbeat or MSC check. If current time > End time, remove the maintenance block from HEARTBEAT.md and notify user.

   Why: OpenClaw agents don't have persistent timers. Heartbeat-based cleanup is the natural pattern — the agent already wakes up periodically.

5. **All actions reported in Telegram output**

   Append a `🤖 Hành động tự động` section to the existing Telegram report format. This section lists what the agent did (auto) or is proposing (ask-first).

   Why: User must always know what the agent changed. Transparency builds trust.

## Risks / Trade-offs

- **False positive classification** — keyword matching may misclassify notifications → Mitigation: for process changes, agent always asks user first. For maintenance, worst case is a temporary unnecessary pause (self-correcting).
- **HEARTBEAT.md conflicts** — if user manually edits HEARTBEAT.md while a maintenance block exists → Mitigation: agent uses structured markers (`## MSC Maintenance Pause`) to find its own blocks, won't touch other content.
- **Missed cleanup** — if agent doesn't run any heartbeat after maintenance ends → Mitigation: cleanup check runs on every MSC check too, not just heartbeats. Next time agent runs, it cleans up.
- **Vietnamese keyword brittleness** — MSC may use different wording → Mitigation: keyword list is in the SKILL.md and can be extended easily. Start with common terms, iterate based on real notifications.

