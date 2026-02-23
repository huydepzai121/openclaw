# 🦞 Hướng dẫn Setup OpenClaw Bot

Hướng dẫn setup OpenClaw gateway với 3 kênh: Telegram + Zalo Bot API + Slack, kèm bot tổng hợp tin tức tự động.

## Yêu cầu

- Docker + Docker Compose
- Telegram Bot Token (tạo từ @BotFather trên Telegram)
- Zalo Bot Token (tạo từ [https://bot.zaloplatforms.com](https://bot.zaloplatforms.com))
- API key cho AI model (OpenAI-compatible provider)
- Brave Search API key (free tại [https://brave.com/search/api/](https://brave.com/search/api/))
- Slack App Token + Bot Token (tạo từ https://api.slack.com/apps)

## Bước 1: Cấu hình .env

Copy `.env.example` thành `.env` và điền các giá trị:

```bash
cp .env.example .env
nano .env
```

Các biến cần điền:

| Biến | Mô tả | Lấy ở đâu |
| --- | --- | --- |
| TELEGRAM_BOT_TOKEN | Token bot Telegram | @BotFather trên Telegram |
| MYPROVIDER_BASE_URL | URL API provider (thêm /v1 nếu OpenAI-compatible) | Provider của bạn |
| MYPROVIDER_API_KEY | API key cho provider | Provider của bạn |
| BRAVE_API_KEY | Key cho web search | https://brave.com/search/api/ |
| TELEGRAM_CHAT_ID | Chat ID nhận tin tức (điền sau khi pairing) | Nhắn @userinfobot trên Telegram |
| ZALO_BOT_TOKEN | Token bot Zalo | https://bot.zaloplatforms.com |
| `SLACK_APP_TOKEN` | App-level token cho Slack (xapp-...) | https://api.slack.com/apps > Basic Information > App-Level Tokens |
| `SLACK_BOT_TOKEN` | Bot User OAuth Token (xoxb-...) | https://api.slack.com/apps > OAuth & Permissions |

## Bước 2: Build và chạy container

```bash
bash setup.sh
```

Hoặc chạy manual:

```bash
docker compose build
docker compose up -d
```

Kiểm tra container:

```bash
docker compose ps
docker compose logs -f
```

## Bước 3: Kết nối Telegram

1. Nhắn tin cho bot trên Telegram (ví dụ @thoisuhuy_bot)
2. Bot sẽ trả về mã pairing
3. Approve pairing:

```bash
docker compose exec openclaw openclaw pairing approve telegram <MÃ_PAIRING>
```

1. Lấy Chat ID — nhắn `/start` cho @userinfobot trên Telegram, copy ID
2. Điền `TELEGRAM_CHAT_ID=<ID>` vào `.env`
3. Restart: `docker compose restart`

## Bước 4: Kết nối Zalo

1. Cài plugin Zalo trong container:

```bash
docker compose exec openclaw openclaw plugins install @openclaw/zalo
```

1. Nếu gặp lỗi `Cannot find module 'zod'`:

```bash
docker compose exec openclaw bash -c "cd /home/claw/.openclaw/extensions/zalo && npm install zod"
docker compose restart
```

1. Nhắn tin cho bot qua Zalo
2. Approve pairing:

```bash
docker compose exec openclaw openclaw pairing approve zalo <MÃ_PAIRING>
```

## Bước 5: Setup cron tin tức tự động

Sau khi pairing Telegram xong và có `TELEGRAM_CHAT_ID`, thêm 3 cron jobs:

### 🌅 Tin sáng (7h)

```bash
docker compose exec openclaw openclaw cron add \
  --name "Tin tức VN buổi sáng" \
  --cron "0 7 * * *" \
  --tz "Asia/Ho_Chi_Minh" \
  --session isolated \
  --message "Bạn là bot tổng hợp tin tức Việt Nam buổi sáng. Hãy search tin tức Việt Nam mới nhất từ đêm qua đến sáng nay. Chọn 5-7 tin nổi bật nhất, đa dạng chủ đề (chính trị, kinh tế, xã hội, công nghệ, thể thao). Với mỗi tin: viết tiêu đề + tóm tắt 2-3 câu + link gốc. Cuối cùng, lưu danh sách tin đã gửi vào file workspace/memory/news-\$(date +%Y-%m-%d).md. Format đẹp cho Telegram, dùng emoji phù hợp. Viết bằng tiếng Việt." \
  --announce \
  --channel telegram \
  --to "<TELEGRAM_CHAT_ID>"
```

### ☀️ Tin trưa (12h)

```bash
docker compose exec openclaw openclaw cron add \
  --name "Tin tức VN buổi trưa" \
  --cron "0 12 * * *" \
  --tz "Asia/Ho_Chi_Minh" \
  --session isolated \
  --message "Bạn là bot cập nhật tin tức Việt Nam buổi trưa. Hãy search tin tức Việt Nam mới nhất trong buổi sáng hôm nay. Focus vào tin kinh tế, thị trường chứng khoán, bất động sản, và công nghệ. Chọn 4-5 tin quan trọng nhất. Với mỗi tin: viết tiêu đề + tóm tắt 2-3 câu + link gốc. Đọc file workspace/memory/news-\$(date +%Y-%m-%d).md nếu có để tránh gửi trùng tin sáng. Append tin mới vào file đó. Format đẹp cho Telegram, dùng emoji phù hợp. Viết bằng tiếng Việt." \
  --announce \
  --channel telegram \
  --to "<TELEGRAM_CHAT_ID>"
```

### 🌙 Tin tối (19h)

```bash
docker compose exec openclaw openclaw cron add \
  --name "Tin tức VN buổi tối" \
  --cron "0 19 * * *" \
  --tz "Asia/Ho_Chi_Minh" \
  --session isolated \
  --message "Bạn là bot tổng kết tin tức Việt Nam buổi tối. Hãy search tin tức Việt Nam nổi bật nhất trong ngày hôm nay. Tổng kết đa dạng: chính trị, kinh tế, xã hội, giải trí, thể thao, quốc tế liên quan VN. Chọn 5-7 tin hay nhất. Với mỗi tin: viết tiêu đề + tóm tắt 2-3 câu + link gốc. Đọc file workspace/memory/news-\$(date +%Y-%m-%d).md nếu có để tránh trùng tin sáng/trưa. Append tin mới vào file đó. Format đẹp cho Telegram, dùng emoji phù hợp. Viết bằng tiếng Việt." \
  --announce \
  --channel telegram \
  --to "<TELEGRAM_CHAT_ID>"
```

Kiểm tra cron đã add:

```bash
docker compose exec openclaw openclaw cron list
```

## Bước 5b: Setup cron tin tức cho Zalo (tùy chọn)

Nếu muốn nhận tin tức qua Zalo nữa, thêm 3 cron jobs tương tự nhưng đổi channel:

```bash
# Lấy Zalo user ID từ lúc pairing (ví dụ: d6818798ffd1168f4fc0)

# Tin sáng 7h - Zalo
docker compose exec openclaw openclaw cron add \
  --name "Tin tức VN buổi sáng (Zalo)" \
  --cron "0 7 * * *" \
  --tz "Asia/Ho_Chi_Minh" \
  --session isolated \
  --message "Tổng hợp 5-7 tin tức Việt Nam nổi bật nhất sáng nay. Đa dạng chủ đề. Mỗi tin: tiêu đề + tóm tắt 2-3 câu + link. Đọc workspace/memory/news-$(date +%Y-%m-%d).md để tránh trùng. Format đẹp, emoji. Tiếng Việt." \
  --announce \
  --channel zalo \
  --to "<ZALO_USER_ID>"

# Tin trưa 12h - Zalo
docker compose exec openclaw openclaw cron add \
  --name "Tin tức VN buổi trưa (Zalo)" \
  --cron "0 12 * * *" \
  --tz "Asia/Ho_Chi_Minh" \
  --session isolated \
  --message "Cập nhật 4-5 tin kinh tế, chứng khoán, công nghệ VN buổi trưa. Đọc workspace/memory/news-$(date +%Y-%m-%d).md để tránh trùng. Format đẹp, emoji. Tiếng Việt." \
  --announce \
  --channel zalo \
  --to "<ZALO_USER_ID>"

# Tin tối 19h - Zalo
docker compose exec openclaw openclaw cron add \
  --name "Tin tức VN buổi tối (Zalo)" \
  --cron "0 19 * * *" \
  --tz "Asia/Ho_Chi_Minh" \
  --session isolated \
  --message "Tổng kết 5-7 tin VN hay nhất trong ngày. Đa dạng chủ đề. Đọc workspace/memory/news-$(date +%Y-%m-%d).md để tránh trùng. Format đẹp, emoji. Tiếng Việt." \
  --announce \
  --channel zalo \
  --to "<ZALO_USER_ID>"
```

Thay `<ZALO_USER_ID>` bằng ID từ lúc pairing Zalo.

## Bước 6: Kết nối Slack

Slack dùng Socket Mode — không cần public URL. Slack là built-in channel, không cần cài plugin.

### Tạo Slack App

1. Vào https://api.slack.com/apps → **Create New App** → **From scratch**
2. Đặt tên app, chọn workspace

### Bật Socket Mode

1. Vào **Settings > Socket Mode** → bật **Enable Socket Mode**
2. Tạo App-Level Token (scope: `connections:write`) → copy token `xapp-...`

### Thêm Bot Permissions

Vào **OAuth & Permissions > Bot Token Scopes**, thêm:
- `app_mentions:read`
- `chat:write`
- `im:history`, `im:read`, `im:write`
- `channels:history`
- `groups:history`

### Bật Events

Vào **Event Subscriptions** → bật **Enable Events**, subscribe:
- `app_mention`
- `message.im`

### Install App

1. Vào **Install App** → **Install to Workspace**
2. Copy **Bot User OAuth Token** (`xoxb-...`)

### Cấu hình .env

Điền 2 token vào `.env`:

```
SLACK_APP_TOKEN=xapp-...
SLACK_BOT_TOKEN=xoxb-...
```

Restart container:

```bash
docker compose restart
```

### Sử dụng

- DM bot trực tiếp trên Slack
- Hoặc invite bot vào channel: `/invite @tên-bot`
- Mention bot: `@tên-bot câu hỏi`

## Cấu trúc project

```
openclaw/
├── .env                    # Credentials (KHÔNG commit)
├── .env.example            # Template
├── config/
│   └── openclaw.json       # Config gateway, channels, model
├── docker-compose.yml      # Container setup
├── Dockerfile.godmode      # Image build
├── setup.sh                # Script setup nhanh
└── workspace/              # Workspace cho bot
    ├── IDENTITY.md          # Bot identity
    ├── USER.md              # User info
    ├── SOUL.md              # Bot personality
    ├── AGENTS.md            # Agent rules
    └── memory/              # Lưu lịch sử tin tức
```

## Lệnh thường dùng

```bash
docker compose logs -f              # Xem logs realtime
docker compose exec openclaw bash   # Shell vào container
docker compose restart              # Restart gateway
docker compose down                 # Dừng container
docker compose up -d --build        # Rebuild và chạy lại
docker compose exec openclaw openclaw cron list    # Xem cron jobs
docker compose exec openclaw openclaw cron remove <ID>  # Xóa cron job
```

## Troubleshooting

### Warning "ANTHROPIC_API_KEY not set"

Không ảnh hưởng — project dùng custom provider (`myprovider`), không cần Anthropic/OpenAI key trực tiếp.

### Brave Search lỗi 422 (country VN)

Brave không hỗ trợ country code `VN`. Bot sẽ tự retry với country `ALL`. Không cần fix.

### Brave Search lỗi 429 (rate limit)

Free plan giới hạn 1 request/giây. Bot sẽ tự retry. Nếu cần nhiều hơn, upgrade plan tại [https://brave.com/search/api/](https://brave.com/search/api/).
