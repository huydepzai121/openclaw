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
| SLACK_APP_TOKEN | App-level token cho Slack (xapp-...) | https://api.slack.com/apps > Basic Information > App-Level Tokens |
| SLACK_BOT_TOKEN | Bot User OAuth Token (xoxb-...) | https://api.slack.com/apps > OAuth & Permissions |

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

4. Lấy Chat ID — nhắn `/start` cho @userinfobot trên Telegram, copy ID
5. Điền `TELEGRAM_CHAT_ID=<ID>` vào `.env`
6. Restart: `docker compose restart`

## Bước 4: Kết nối Zalo

1. Cài plugin Zalo trong container:

```bash
docker compose exec openclaw openclaw plugins install @openclaw/zalo
```

2. Nếu gặp lỗi `Cannot find module 'zod'`:

```bash
docker compose exec openclaw bash -c "cd /home/claw/.openclaw/extensions/zalo && npm install zod"
docker compose restart
```

3. Nhắn tin cho bot qua Zalo
4. Approve pairing:

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

## Bước 7: Train tài liệu cho AI

Bot OpenClaw đọc tất cả files trong `workspace/` trước khi trả lời. Đây là cách "train" bot theo kiến thức riêng — không cần code, chỉ cần viết file.

### Cơ chế hoạt động

- Bot đọc files trong `workspace/` mỗi khi bắt đầu session mới
- Thay đổi file → bot tự đọc lại lần chat tiếp theo (không cần restart container)
- Files quan trọng nhất: `SOUL.md` (tính cách), `IDENTITY.md` (vai trò), `knowledge/` (kiến thức)

### Tạo knowledge files

Tạo thư mục `workspace/knowledge/` và thêm file `.md` cho mỗi chủ đề:

```bash
mkdir -p workspace/knowledge
```

Ví dụ cấu trúc:

```
workspace/knowledge/
├── phapluat-sources.md      # Nguồn văn bản pháp luật VN
├── muasamcong-guide.md      # Hướng dẫn hệ thống mua sắm công
├── san-pham.md              # Catalog sản phẩm/dịch vụ
├── faq.md                   # Câu hỏi thường gặp
└── quy-trinh.md             # Quy trình nội bộ
```

### Các loại tài liệu có thể train

| Loại | Mô tả | Ví dụ |
| --- | --- | --- |
| Nguồn tin | URLs đáng tin cậy, cách search | Danh sách website pháp luật VN |
| FAQ | Câu hỏi thường gặp + trả lời | FAQ sản phẩm, chính sách |
| Quy trình | Hướng dẫn step-by-step | Quy trình đấu thầu, mua hàng |
| Catalog | Bảng giá, mô tả sản phẩm | Danh mục sản phẩm + giá |
| Hướng dẫn trả lời | Cách bot nên respond | Tone, style, từ ngữ cần dùng |
| Kiến thức chuyên ngành | Domain knowledge | Luật đấu thầu, quy định thuế |

### Tips viết knowledge file hiệu quả

- **Structured > Free-form** — dùng headings, bullet points, tables
- **Cụ thể > Chung chung** — "Giá sản phẩm A: 500.000đ" tốt hơn "giá hợp lý"
- **Ghi rõ quy tắc** — dùng `QUAN TRỌNG:` hoặc `⚠️` cho thông tin bot PHẢI tuân thủ
- **Cập nhật thường xuyên** — kiến thức cũ = trả lời sai
- **Một chủ đề/file** — dễ quản lý, dễ cập nhật

### Ví dụ knowledge file

```markdown
# Sản phẩm công ty ABC

## Danh mục sản phẩm

| Sản phẩm | Giá | Mô tả |
| --- | --- | --- |
| Gói Basic | 500.000đ/tháng | 10 users, 5GB storage |
| Gói Pro | 1.500.000đ/tháng | 50 users, 50GB storage |
| Gói Enterprise | Liên hệ | Unlimited |

## QUAN TRỌNG: Quy tắc trả lời

- Luôn hỏi nhu cầu khách trước khi tư vấn gói
- Không bao giờ giảm giá — chỉ có chương trình khuyến mãi theo mùa
- Nếu khách hỏi về Enterprise, yêu cầu để lại SĐT để sales liên hệ
```

### Tùy chỉnh tính cách bot

Sửa `workspace/SOUL.md` để thay đổi cách bot giao tiếp:

```markdown
# SOUL.md
Bạn là trợ lý tư vấn chuyên nghiệp của công ty ABC.
- Giọng điệu: thân thiện, chuyên nghiệp
- Luôn xưng "em", gọi khách là "anh/chị"
- Trả lời ngắn gọn, đi thẳng vào vấn đề
- Nếu không biết, nói "Em sẽ kiểm tra và phản hồi lại ạ"
```

Sửa `workspace/IDENTITY.md` để thay đổi vai trò:

```markdown
# IDENTITY.md
Tên: Trợ lý ABC
Vai trò: Tư vấn sản phẩm và hỗ trợ khách hàng
Công ty: ABC Corp
```

## Bước 8: Setup cron rà soát pháp luật & mua sắm công (tùy chọn)

2 cron jobs chạy thứ 2 hàng tuần, 8h sáng giờ VN. Bot sẽ search + tổng hợp + so sánh điểm mới vs cũ.

### 📜 Rà soát văn bản pháp luật

```bash
docker compose exec openclaw openclaw cron add \
  --name "Rà soát văn bản pháp luật tuần" \
  --cron "0 8 * * 1" \
  --tz "Asia/Ho_Chi_Minh" \
  --session isolated \
  --message "Bạn là chuyên gia rà soát văn bản pháp luật Việt Nam. Đọc file workspace/knowledge/phapluat-sources.md để biết nguồn tin đáng tin cậy. Hãy search các văn bản pháp luật mới được ban hành hoặc có hiệu lực trong tuần vừa qua (Nghị định, Thông tư, Quyết định, Luật, Nghị quyết). Tất cả lĩnh vực: đấu thầu, đầu tư công, thuế, doanh nghiệp, lao động, bất động sản, chứng khoán, ngân hàng. Với mỗi văn bản: ghi rõ số hiệu, ngày ban hành, cơ quan ban hành, tóm tắt nội dung chính, và ĐIỂM MỚI THAY ĐỔI so với quy định cũ. Lưu vào file workspace/memory/phapluat-\$(date +%Y-%W).md. Format đẹp cho Telegram, dùng emoji. Viết bằng tiếng Việt." \
  --announce \
  --channel telegram \
  --to "<TELEGRAM_CHAT_ID>"
```

### 🏛️ Rà soát thông báo mua sắm công

```bash
docker compose exec openclaw openclaw cron add \
  --name "Rà soát muasamcong tuần" \
  --cron "0 8 * * 1" \
  --tz "Asia/Ho_Chi_Minh" \
  --session isolated \
  --message "Bạn là chuyên gia theo dõi hệ thống mua sắm công Việt Nam. Đọc file workspace/knowledge/muasamcong-guide.md để biết context. Hãy search thông tin mới nhất từ muasamcong.mpi.gov.vn trong tuần vừa qua. Focus: (1) Thông báo hệ thống mới, (2) Thay đổi quy trình đấu thầu/mua sắm công, (3) Hướng dẫn mới cho nhà thầu/bên mời thầu, (4) Văn bản pháp luật liên quan đấu thầu. Tóm tắt rõ ràng, ghi ngày và nguồn. So sánh với quy trình cũ nếu có thay đổi. Lưu vào file workspace/memory/muasamcong-\$(date +%Y-%W).md. Format đẹp cho Telegram, dùng emoji. Viết bằng tiếng Việt." \
  --announce \
  --channel telegram \
  --to "<TELEGRAM_CHAT_ID>"
```

Thay `<TELEGRAM_CHAT_ID>` bằng Chat ID của bạn.

## Bước 9: API Integration (cho trang không cần browser)

### Cách tiếp cận

Nhiều trang web (ví dụ muasamcong.mpi.gov.vn) cung cấp API JSON trực tiếp. OpenClaw agent có thể gọi API bằng `exec curl` — không cần browser headless hay MCP server.

### Ví dụ: Gọi API Mua Sắm Công

```bash
exec curl -s -X POST \
  https://muasamcong.mpi.gov.vn/o/egp-portal-notification-system/services/get-list \
  -H "Content-Type: application/json" \
  -d '{"page": 1, "pageSize": 10}'
```

Agent parse JSON response trực tiếp — nhanh, ổn định, không phụ thuộc Chromium/Playwright.

### Cron rà soát mua sắm công

Xóa cron cũ và thêm cron mới với skill msc-checker:

```bash
# Xóa cron cũ
docker compose exec openclaw openclaw cron list
docker compose exec openclaw openclaw cron remove <ID_CRON_MUASAMCONG>

# Thêm cron mới — dùng skill msc-checker
docker compose exec openclaw openclaw cron add \
  --name "Rà soát muasamcong tuần" \
  --cron "0 8 * * 1" \
  --tz "Asia/Ho_Chi_Minh" \
  --session isolated \
  --message "Dùng skill msc-checker để kiểm tra MSC tuần này" \
  --announce \
  --channel telegram \
  --to "<TELEGRAM_CHAT_ID>"
```

## Bước 10: Custom Skills & Sub-agents

### Skills là gì?

Skills là folder chứa file `SKILL.md`, dạy agent cách dùng tools hoặc thực hiện một tác vụ cụ thể. Mỗi skill là một "bài hướng dẫn" mà agent đọc khi cần — giống như SOP (Standard Operating Procedure).

Skills được đặt trong `workspace/skills/`:

```
workspace/skills/
├── msc-checker/
│   └── SKILL.md        # Hướng dẫn kiểm tra mua sắm công
├── another-skill/
│   └── SKILL.md
```

### Sub-agents là gì?

Sub-agents là các agent session chạy nền (background), được spawn qua `sessions_spawn`. Mỗi sub-agent chạy isolated — có context riêng, không ảnh hưởng session chính. Phù hợp cho tác vụ nặng hoặc chạy song song.

### Skill msc-checker

Skill `msc-checker` đã được tạo sẵn trong `workspace/skills/msc-checker/`. Skill này hướng dẫn agent dùng API trực tiếp (exec curl) để kiểm tra thông tin mới từ muasamcong.mpi.gov.vn.

### Cấu hình sub-agents

Config sub-agents đã được thêm vào `config/openclaw.json`:

```json
{
  "agents": {
    "defaults": {
      "subagents": {
        "maxSpawnDepth": 2,
        "maxConcurrent": 3,
        "maxChildrenPerAgent": 3
      }
    }
  },
  "sessions": {
    "spawn": {
      "enabled": true
    }
  }
}
```

### Test sub-agents

```bash
# Liệt kê sub-agents đang chạy
docker compose exec openclaw openclaw subagents list

# Spawn sub-agent chạy skill msc-checker
docker compose exec openclaw openclaw subagents spawn msc "Kiểm tra MSC"
```

### Tạo skill mới

1. Tạo folder trong `workspace/skills/`:

```bash
mkdir -p workspace/skills/ten-skill
```

2. Viết file `SKILL.md` trong folder đó:

```markdown
# Skill: Tên Skill

Mô tả ngắn skill làm gì.

## Khi nào dùng
- Điều kiện 1
- Điều kiện 2

## Cách thực hiện
1. Bước 1
2. Bước 2
3. Bước 3

## Lưu ý
- Lưu ý quan trọng
```

Agent sẽ tự đọc `SKILL.md` khi cần thực hiện tác vụ liên quan.

### Cập nhật cron MSC dùng skill

Cron mua sắm công ở Bước 8 hoặc Bước 9 có thể đơn giản hóa message nhờ skill. Xóa cron cũ và thêm cron mới:

```bash
# Xóa cron cũ
docker compose exec openclaw openclaw cron list
docker compose exec openclaw openclaw cron remove <ID_CRON_MUASAMCONG>

# Thêm cron mới — message ngắn gọn, agent tự đọc skill
docker compose exec openclaw openclaw cron add \
  --name "Rà soát muasamcong tuần (skill)" \
  --cron "0 8 * * 1" \
  --tz "Asia/Ho_Chi_Minh" \
  --session isolated \
  --message "Dùng skill msc-checker để kiểm tra MSC tuần này" \
  --announce \
  --channel telegram \
  --to "<TELEGRAM_CHAT_ID>"
```

Message chỉ cần 1 dòng — toàn bộ hướng dẫn chi tiết đã nằm trong `workspace/skills/msc-checker/SKILL.md`.

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
    ├── knowledge/           # Tài liệu train cho AI
    │   ├── phapluat-sources.md   # Nguồn văn bản pháp luật
    │   └── muasamcong-guide.md   # Hướng dẫn mua sắm công
    ├── skills/              # Custom skills cho agent
    │   └── msc-checker/     # Skill kiểm tra mua sắm công
    │       └── SKILL.md
    └── memory/              # Lưu lịch sử tin tức, pháp luật
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
