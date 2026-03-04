## Why

The `msc-checker` skill currently fetches notifications from muasamcong.mpi.gov.vn and sends a formatted report to Telegram — but it never *reacts* to the content. When MSC announces system maintenance, the agent keeps checking during downtime (wasting API calls and getting errors). When MSC changes procurement processes, the knowledge guide (`muasamcong-guide.md`) becomes stale silently.

Adding conditional actions based on notification content makes the agent smarter: it adapts its own behavior (pause during maintenance) and keeps knowledge current (update guide on process changes) — while always informing the user what it did.

## What Changes

- Add a "Conditional Actions" section to `workspace/skills/msc-checker/SKILL.md` with two reaction rules:
  - **Maintenance detected** (notiType=3, or title contains maintenance keywords) → auto-update `HEARTBEAT.md` with a pause reminder + scheduled cleanup after maintenance window ends. No user confirmation needed.
  - **Process change detected** (notiType=2, title contains process/procedure change keywords) → ask user for confirmation before updating `workspace/knowledge/muasamcong-guide.md` with the new information.
- Extend the Telegram report output format to include an "Automated Actions" section at the bottom, showing what the agent did or is proposing to do.
- Add cleanup logic: after maintenance window passes, agent removes the HEARTBEAT pause reminder automatically and notifies user.

## Capabilities

### New Capabilities
- `msc-smart-reactions`: Conditional action logic — classify MSC notifications and trigger appropriate reactions (auto-update HEARTBEAT for maintenance, ask-then-update knowledge guide for process changes, notify user of all actions via Telegram report)

### Modified Capabilities

## Impact

- `workspace/skills/msc-checker/SKILL.md` — new "Conditional Actions" section with classification rules, action logic, and output format changes
- `workspace/HEARTBEAT.md` — will be dynamically updated by the agent during maintenance windows
- `workspace/knowledge/muasamcong-guide.md` — will be updated (with user confirmation) when process changes are detected
- Telegram report format — new "Automated Actions" section appended to existing output

