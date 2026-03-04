## ADDED Requirements

### Requirement: MSC checker skill declares available tools
The `msc-checker` SKILL.md SHALL include a "Tools Available" section before the step-by-step flow, explicitly listing the OpenClaw built-in tools the agent can use without any special configuration:
- `exec` — run shell commands (docs: https://docs.openclaw.ai/tools/exec). Key param: `command`. Sandboxing off by default.
- `web_search` — search the web via Brave/Perplexity/Gemini (docs: https://docs.openclaw.ai/tools/web). Key param: `query`.
- `web_fetch` — HTTP GET + readable extraction, HTML → markdown/text (docs: https://docs.openclaw.ai/tools/web). Key param: `url`.

#### Scenario: Agent reads skill and knows it can use exec
- **WHEN** the agent reads `workspace/skills/msc-checker/SKILL.md`
- **THEN** it SHALL find a clear statement that `exec` tool is available for running curl/shell commands, with no special permissions needed

### Requirement: MSC checker skill includes anti-pattern guard
The `msc-checker` SKILL.md SHALL include a "NEVER" section that explicitly forbids the agent from claiming it lacks tool permissions, suggesting browser enablement, or asking the user to run curl manually.

#### Scenario: Agent does not claim missing permissions
- **WHEN** the agent is asked to run the msc-checker skill
- **THEN** it SHALL NOT respond with messages about lacking tool permissions or needing browser enabled

#### Scenario: Agent does not suggest manual curl
- **WHEN** the agent is asked to check MSC notifications
- **THEN** it SHALL NOT ask the user to run curl commands manually and send results back

### Requirement: Knowledge file clarifies tool availability
The `workspace/knowledge/muasamcong-guide.md` SHALL include a note in the API section stating that `exec` (https://docs.openclaw.ai/tools/exec) and `web_fetch` (https://docs.openclaw.ai/tools/web) are always available to the agent for calling APIs.

#### Scenario: Guide confirms exec availability
- **WHEN** the agent reads the muasamcong guide API section
- **THEN** it SHALL find confirmation that exec and web_fetch require no special permissions

### Requirement: TOOLS.md documents OpenClaw environment tools
The `workspace/TOOLS.md` SHALL include a section listing the built-in OpenClaw tools with correct names, key parameters, and doc links:
- `exec` (command) — https://docs.openclaw.ai/tools/exec
- `web_search` (query) — https://docs.openclaw.ai/tools/web
- `web_fetch` (url) — https://docs.openclaw.ai/tools/web

#### Scenario: TOOLS.md has environment tools section
- **WHEN** the agent reads `workspace/TOOLS.md`
- **THEN** it SHALL find a section describing available built-in tools with their key parameters and doc links

