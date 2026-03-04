## Context

The OpenClaw agent runs inside a Docker container with full dev tools and has access to built-in tools by default (docs: https://docs.openclaw.ai/tools/):

- `exec` — Run shell commands in the workspace. Sandboxing is off by default, so exec runs directly on the host. Supports foreground + background execution. (docs: https://docs.openclaw.ai/tools/exec)
- `web_search` — Search the web via Brave Search API (default), Perplexity Sonar, or Gemini. Returns structured results. (docs: https://docs.openclaw.ai/tools/web)
- `web_fetch` — HTTP fetch + readable extraction (HTML → markdown/text). Does NOT execute JavaScript. (docs: https://docs.openclaw.ai/tools/web)

However, when a user asks the agent to run the `msc-checker` skill, the agent sometimes responds saying it "lacks tool permissions" and suggests enabling browser — which is completely wrong.

The root cause: the skill and knowledge files describe WHAT to do (call API with exec curl) but never explicitly state that the agent ALREADY HAS these tools. The agent's LLM infers (incorrectly) that it needs special permissions.

## Goals / Non-Goals

**Goals:**
- Make it unambiguous in skill/knowledge docs that the agent has `exec` (https://docs.openclaw.ai/tools/exec), `web_search`, and `web_fetch` (https://docs.openclaw.ai/tools/web) tools available — with key params documented
- Add anti-pattern guards so the agent never claims it can't run curl or suggests browser enablement
- Document available tools in TOOLS.md with correct names, key params, and doc links

**Non-Goals:**
- Not changing any runtime config or tool permissions
- Not changing the API endpoints or curl commands themselves
- Not modifying the cron job setup

## Decisions

1. **Add explicit "Tools Available" section at the TOP of msc-checker SKILL.md** — Placing it before the flow steps ensures the agent reads it first. Format: a clear list of tools it can use, with a "NEVER" anti-pattern block.

2. **Add a short note in muasamcong-guide.md** — Less prominent than the skill (since the skill is the primary instruction), but still clarifying that exec curl is always available.

3. **Add OpenClaw environment section to TOOLS.md** — This is the canonical place for environment-specific tool info. Other skills can reference it too.

4. **Use strong "NEVER/DO NOT" language in anti-patterns** — The agent needs unambiguous negative instructions to override its tendency to hedge about permissions.

## Risks / Trade-offs

- **[Low risk] Over-instruction** — Adding too many "NEVER do X" rules can make the skill verbose. Mitigation: keep the anti-pattern section compact (3-4 bullet points max).
- **[Low risk] Agent still ignores instructions** — LLMs can still hallucinate despite clear docs. Mitigation: placing the tool availability section at the very top of the skill maximizes visibility.

