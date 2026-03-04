## 1. Config Fix

- [x] 1.1 Update `tools.allow` in `config/openclaw.json` — change `["group:ui"]` to `["group:ui", "group:runtime", "group:web"]` ← (verify: JSON is valid, allowlist contains all 3 groups, no other config keys changed)

## 2. Skill Docs Update

- [x] 2.1 Update anti-pattern section in `workspace/skills/msc-checker/SKILL.md` — add a diagnostic note: if a built-in tool is genuinely unavailable, check `tools.allow` in `config/openclaw.json` and ensure `group:runtime` + `group:web` are included ← (verify: anti-pattern section still has all 4 original KHÔNG rules plus the new diagnostic note, SKILL.md is well-formed)

