## ADDED Requirements

### Requirement: Tool allowlist includes runtime and web groups
The `config/openclaw.json` `tools.allow` array SHALL include `group:runtime` and `group:web` in addition to `group:ui`, so the agent has access to `exec`, `bash`, `process`, `web_search`, and `web_fetch` tools.

#### Scenario: Agent can use exec tool
- **WHEN** the agent attempts to call the `exec` tool with a curl command
- **THEN** the tool call SHALL succeed (not be blocked by tool policy)

#### Scenario: Agent can use web_search tool
- **WHEN** the agent attempts to call `web_search` with a query
- **THEN** the tool call SHALL succeed (not be blocked by tool policy)

#### Scenario: Agent can use web_fetch tool
- **WHEN** the agent attempts to call `web_fetch` with a URL
- **THEN** the tool call SHALL succeed (not be blocked by tool policy)

### Requirement: MSC checker skill anti-pattern includes config diagnosis
The `workspace/skills/msc-checker/SKILL.md` anti-pattern section SHALL include guidance for diagnosing tool policy issues, directing the agent to check `tools.allow` in config if a built-in tool is genuinely unavailable.

#### Scenario: Agent diagnoses missing tool as config issue
- **WHEN** a built-in tool (exec, web_search, web_fetch) is genuinely not available at runtime
- **THEN** the agent SHALL suggest checking `tools.allow` in `config/openclaw.json` rather than claiming the tool doesn't exist

