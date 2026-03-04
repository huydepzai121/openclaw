## REMOVED Requirements

### Requirement: Browser config block
The `browser` configuration block in `config/openclaw.json` SHALL be removed entirely. The project does not use any browser functionality.

**Reason**: Dead configuration — browser was never enabled or used.
**Migration**: No migration needed. Remove the `"browser": { "enabled": false }` block from config.

#### Scenario: Config without browser block
- **WHEN** the config file `config/openclaw.json` is loaded
- **THEN** there SHALL be no `browser` key present

### Requirement: Browser references in documentation
All mentions of "browser", "headless", "Chromium", and "Playwright" SHALL be removed from documentation files. Affected text SHALL be reworded to describe the API-first approach without contrasting it against browser-based approaches.

**Reason**: These references are misleading — the project never used browsers.
**Migration**: Reword affected sentences to stand on their own.

#### Scenario: SETUP.md cleaned
- **WHEN** reading `SETUP.md` section 9
- **THEN** the section title and body text SHALL NOT contain "browser", "headless", "Chromium", or "Playwright"

#### Scenario: muasamcong-guide cleaned
- **WHEN** reading `workspace/knowledge/muasamcong-guide.md`
- **THEN** the API section SHALL NOT reference "browser" or "headless" in headers or body text

#### Scenario: msc-checker skill cleaned
- **WHEN** reading `workspace/skills/msc-checker/SKILL.md`
- **THEN** the context description SHALL NOT mention "browser"

