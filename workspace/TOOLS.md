# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

## OpenClaw Built-in Tools

Các tool sau luôn có sẵn — không cần cấu hình thêm:

| Tool | Key Param | Mô tả | Docs |
|------|-----------|-------|------|
| `exec` | `command` | Chạy shell commands (curl, jq, python, etc.). Sandboxing off by default. | https://docs.openclaw.ai/tools/exec |
| `web_search` | `query` | Tìm kiếm web qua Brave/Perplexity/Gemini. | https://docs.openclaw.ai/tools/web |
| `web_fetch` | `url` | HTTP GET + trích xuất nội dung (HTML → markdown/text). Không chạy JS. | https://docs.openclaw.ai/tools/web |

---

Add whatever helps you do your job. This is your cheat sheet.
