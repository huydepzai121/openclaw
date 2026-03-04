## 1. Skill Definition

- [x] 1.1 Create `workspace/skills/vbpl-reviewer/SKILL.md` with full SOP including: context, tools available, anti-patterns, step-by-step flow for web_search discovery, web_fetch detail extraction, deduplication logic, domain categorization keywords, and Telegram output format ← (verify: SKILL.md follows msc-checker pattern, all spec requirements for scanning and reporting are covered, domain keywords and emoji mappings match spec, document type ordering matches spec)

## 2. Knowledge Base Update

- [x] 2.1 Update `workspace/knowledge/phapluat-sources.md` to add domain keyword lists used by the skill (đấu thầu, thuế, lao động, etc.) and document number regex patterns for deduplication ← (verify: keyword lists match domain emoji mapping in spec, regex patterns cover all standard document number formats listed in scanning spec)

## 3. Cron Setup Documentation

- [x] 3.1 Add cron job setup instructions as a comment block at the end of SKILL.md with the exact `openclaw cron add` command for weekly execution ← (verify: cron command uses --session isolated, --channel telegram, correct timezone Asia/Ho_Chi_Minh, message references the skill name)

