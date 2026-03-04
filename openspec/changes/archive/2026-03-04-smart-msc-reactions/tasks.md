## 1. Notification Classification

- [x] 1.1 Add "Conditional Actions" section to `workspace/skills/msc-checker/SKILL.md` — insert after "Bước 5: Tổng hợp kết quả", before "Output Format". Define classification rules: maintenance (notiType=3 OR title keywords), process change (notiType=2 AND title keywords), informational (everything else)
- [x] 1.2 Add keyword lists to the classification section — maintenance keywords: `bảo trì|ngừng hoạt động|tạm ngưng|downtime|nâng cấp hệ thống`, process change keywords: `quy trình|thay đổi|cập nhật|sửa đổi|quy định mới` ← (verify: keywords cover common MSC notification titles, classification logic matches spec scenarios)

## 2. Maintenance Auto-Action (HEARTBEAT.md)

- [x] 2.1 Add maintenance reaction instructions to SKILL.md — when maintenance detected: auto-append structured block to `workspace/HEARTBEAT.md` with Status/Start/End/Source/Action fields in ISO 8601 format
- [x] 2.2 Add time parsing guidance — extract start/end from notification content; if unparseable, use startDate as Start and Start+8h as End
- [x] 2.3 Add duplicate detection rule — check if commonNotificationId already exists in HEARTBEAT.md before adding
- [x] 2.4 Add maintenance skip logic — on each check, if active maintenance block exists and current time < End, skip MSC API call and report "MSC đang bảo trì, bỏ qua check lần này" ← (verify: HEARTBEAT.md format matches design, duplicate detection works, skip logic is clear)

## 3. Maintenance Cleanup

- [x] 3.1 Add cleanup instructions to SKILL.md — on each heartbeat/MSC check, if current time > End of any maintenance block, remove that block from HEARTBEAT.md
- [x] 3.2 Add cleanup notification — after removing expired block, include "Bảo trì MSC đã kết thúc, đã resume check tự động" in Telegram report ← (verify: cleanup triggers correctly, notification text matches spec)

## 4. Process Change Ask-First Action (muasamcong-guide.md)

- [x] 4.1 Add process change reaction instructions to SKILL.md — when process change detected: summarize the change, send Telegram message asking user "Phát hiện thay đổi quy trình: <summary>. Cập nhật muasamcong-guide.md không? (yes/no)"
- [x] 4.2 Add confirmation handling — if user confirms: update relevant section in `workspace/knowledge/muasamcong-guide.md` with new info + date annotation. If user declines: log skipped update in daily memory file ← (verify: ask-first flow matches spec scenarios, guide update includes date annotation)

## 5. Telegram Report Format Update

- [x] 5.1 Update the "Output Format — Báo cáo Telegram" section in SKILL.md — append `🤖 **Hành động tự động:**` section template at the bottom of the report format
- [x] 5.2 Add conditional display rules — show "✅ Đã cập nhật..." for auto-actions taken, "❓ Phát hiện thay đổi..." for proposed actions, omit section entirely if no actions ← (verify: all three report scenarios from spec are covered — auto-action, proposed action, no action)

