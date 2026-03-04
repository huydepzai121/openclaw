---
name: msc-checker
description: Kiểm tra thông báo mới trên muasamcong.mpi.gov.vn bằng API trực tiếp (exec curl). Gọi API notification system, parse JSON, tổng hợp kết quả.
metadata: {"openclaw": {"emoji": "🏛️"}}
---

# 🏛️ MSC Checker — Kiểm tra thông báo Mua sắm công

## Context

Hệ thống muasamcong.mpi.gov.vn (MSC) có API JSON nội bộ trả danh sách thông báo. Skill này dùng **exec curl** để gọi API trực tiếp.

Base URL: `https://muasamcong.mpi.gov.vn/o/egp-portal-notification-system/services`

## Tools Available — Luôn có sẵn, KHÔNG cần cấu hình thêm

Agent luôn có các built-in tools sau:

| Tool | Key Param | Mô tả | Docs |
|------|-----------|-------|------|
| `exec` | `command` | Chạy shell commands (curl, jq, etc.). Sandboxing off by default → chạy trực tiếp trên host. | https://docs.openclaw.ai/tools/exec |
| `web_search` | `query` | Tìm kiếm web qua Brave/Perplexity/Gemini. Trả kết quả có cấu trúc. | https://docs.openclaw.ai/tools/web |
| `web_fetch` | `url` | HTTP GET + trích xuất nội dung (HTML → markdown/text). Không chạy JavaScript. | https://docs.openclaw.ai/tools/web |

→ Để gọi API MSC: dùng `exec` với `command: "curl -s -X POST ..."` — luôn hoạt động, không cần quyền đặc biệt.

## ⛔ KHÔNG ĐƯỢC LÀM — Anti-patterns

- **KHÔNG** nói "thiếu quyền tool" hoặc "không có quyền chạy curl" — agent LUÔN có `exec`
- **KHÔNG** gợi ý bật browser (`browser.enabled=true`) — không liên quan đến skill này
- **KHÔNG** yêu cầu user chạy curl thủ công rồi gửi kết quả lại — agent tự chạy được
- **KHÔNG** nói "cần cấu hình thêm" để gọi API — `exec curl` luôn sẵn sàng

Nếu `exec curl` thất bại → đó là lỗi mạng/API, KHÔNG phải lỗi quyền. Xử lý theo phần "Fallback khi API fail" bên dưới.

> 🔧 **Chẩn đoán:** Nếu một built-in tool (`exec`, `web_search`, `web_fetch`) thực sự không khả dụng tại runtime, kiểm tra `tools.allow` trong `config/openclaw.json` — đảm bảo có `group:runtime` và `group:web` trong allowlist.

## Loại thông báo (notiType)

| Code | Tên | Ưu tiên |
|------|-----|---------|
| 2 | Thông báo về Hệ thống | ⭐ Cao |
| 3 | Lịch bảo trì hệ thống | ⭐ Cao |
| 5 | Hành vi hạn chế cạnh tranh | ⭐ Cao |
| 1 | Thông báo quản trị | Trung bình |
| 4 | Thông báo về các khóa đào tạo | Thấp |
| 6 | Thông báo khác | Thấp |

## Step-by-step Flow

### Bước 1: Lấy thông báo hệ thống (notiType=2)

```bash
curl -s -X POST \
  'https://muasamcong.mpi.gov.vn/o/egp-portal-notification-system/services/get-list' \
  -H 'Content-Type: application/json' \
  -d '{"pageSize": 10, "pageNumber": 0, "commonNoti": {"notiType": "2"}}'
```

Response JSON: `page.content[]` chứa:
- `title` — tiêu đề thông báo
- `content` — nội dung (HTML, cần strip tags)
- `createdDate` — ngày tạo
- `startDate` — ngày bắt đầu
- `viewCount` — lượt xem
- `commonNotificationId` — UUID
- `isAttachment` — có file đính kèm không
- `docFilePath`, `docFileId` — thông tin file

### Bước 2: Lấy lịch bảo trì (notiType=3)

```bash
curl -s -X POST \
  'https://muasamcong.mpi.gov.vn/o/egp-portal-notification-system/services/get-list' \
  -H 'Content-Type: application/json' \
  -d '{"pageSize": 10, "pageNumber": 0, "commonNoti": {"notiType": "3"}}'
```

### Bước 3: Lấy thông báo hạn chế cạnh tranh (notiType=5)

```bash
curl -s -X POST \
  'https://muasamcong.mpi.gov.vn/o/egp-portal-notification-system/services/get-list' \
  -H 'Content-Type: application/json' \
  -d '{"pageSize": 5, "pageNumber": 0, "commonNoti": {"notiType": "5"}}'
```

### Bước 4: Bổ sung bằng web_search (nếu cần)

```
web_search → query="thông báo mới" site:muasamcong.mpi.gov.vn
```

Các query bổ sung:
- `muasamcong bảo trì hệ thống 2026`
- `muasamcong thay đổi quy trình đấu thầu`

### Bước 5: Tổng hợp kết quả

1. Parse JSON từ Bước 1-3 — extract title, date, content (strip HTML tags)
2. Sắp xếp theo ngày mới nhất
3. Cross-check với web_search (Bước 4)
4. Phân loại: bảo trì / nâng cấp / thay đổi quy trình / hướng dẫn mới

> ⚠️ Content trong response là HTML — strip tags trước khi hiển thị. Ví dụ: `<p>Nội dung</p>` → `Nội dung`

## Bước 6: Phân loại thông báo & Hành động có điều kiện

Sau khi tổng hợp kết quả, phân loại từng thông báo vào 1 trong 3 nhóm:

### Quy tắc phân loại

| Nhóm | Điều kiện | Hành động |
|------|-----------|-----------|
| 🔧 **Bảo trì** | `notiType=3` HOẶC title chứa keyword bảo trì | Tự động cập nhật HEARTBEAT.md (xem Bước 7) |
| 📋 **Thay đổi quy trình** | `notiType=2` VÀ title chứa keyword quy trình | Hỏi user trước khi cập nhật guide (xem Bước 8) |
| ℹ️ **Thông tin chung** | Tất cả thông báo còn lại | Chỉ báo cáo, không hành động |

### Keyword lists

**Bảo trì** — match bất kỳ keyword nào (case-insensitive):
```
bảo trì|ngừng hoạt động|tạm ngưng|downtime|nâng cấp hệ thống
```

**Thay đổi quy trình** — match bất kỳ keyword nào (case-insensitive):
```
quy trình|thay đổi|cập nhật|sửa đổi|quy định mới
```

> ⚠️ `notiType=2` một mình KHÔNG đủ để phân loại là "thay đổi quy trình" — phải match thêm keyword trong title. Nếu `notiType=2` mà title không chứa keyword quy trình → phân loại là "thông tin chung".

## Bước 7: Hành động — Bảo trì (Tự động)

Khi phát hiện thông báo thuộc nhóm **🔧 Bảo trì**, thực hiện tự động (KHÔNG cần hỏi user):

### 7.1 Kiểm tra trùng lặp

Trước khi thêm block mới, kiểm tra `workspace/HEARTBEAT.md`:
- Tìm `## MSC Maintenance Pause` blocks đã có
- Nếu `commonNotificationId` của thông báo hiện tại đã tồn tại trong dòng `Source:` → **bỏ qua**, không thêm block trùng

### 7.2 Parse thời gian bảo trì

Trích xuất thời gian start/end từ nội dung thông báo (content đã strip HTML):
- Tìm pattern ngày giờ trong content (ví dụ: "từ 22:00 ngày 05/03 đến 06:00 ngày 06/03")
- Chuyển sang ISO 8601 với timezone `+07:00`

**Fallback nếu không parse được thời gian:**
- Start = `startDate` của thông báo (từ API response)
- End = Start + 8 giờ

### 7.3 Thêm block bảo trì vào HEARTBEAT.md

Append block sau vào cuối `workspace/HEARTBEAT.md`:

```markdown
## MSC Maintenance Pause
- Status: active
- Start: <ISO 8601 datetime, ví dụ: 2026-03-05T22:00+07:00>
- End: <ISO 8601 datetime, ví dụ: 2026-03-06T06:00+07:00>
- Source: MSC notification <commonNotificationId>
- Action: Skip msc-checker until End time, then remove this block
```

### 7.4 Skip logic khi đang bảo trì

**Trước khi gọi API MSC** (trước Bước 1), kiểm tra `workspace/HEARTBEAT.md`:
- Nếu tồn tại block `## MSC Maintenance Pause` với `Status: active` VÀ thời gian hiện tại < End
- → **Bỏ qua toàn bộ MSC API call** (Bước 1-5)
- → Báo cáo: "MSC đang bảo trì, bỏ qua check lần này"
- → Vẫn thực hiện cleanup check (Bước 9)

## Bước 8: Hành động — Thay đổi quy trình (Hỏi trước)

Khi phát hiện thông báo thuộc nhóm **📋 Thay đổi quy trình**, PHẢI hỏi user trước khi hành động:

### 8.1 Tóm tắt và hỏi user

1. Tóm tắt nội dung thay đổi quy trình từ thông báo (1-2 câu)
2. Gửi tin nhắn Telegram hỏi user:
   ```
   Phát hiện thay đổi quy trình: <tóm tắt>. Cập nhật muasamcong-guide.md không? (yes/no)
   ```
3. **Chờ user phản hồi** — KHÔNG tự động cập nhật

### 8.2 Xử lý phản hồi

- **User xác nhận (yes/có/ok/đồng ý):**
  - Cập nhật section liên quan trong `workspace/knowledge/muasamcong-guide.md` với thông tin mới
  - Thêm annotation ngày: `(Cập nhật: YYYY-MM-DD — theo thông báo MSC <commonNotificationId>)`
  - Báo cáo: "✅ Đã cập nhật muasamcong-guide.md"

- **User từ chối (no/không/skip/bỏ qua):**
  - KHÔNG sửa muasamcong-guide.md
  - Ghi vào daily memory file (`workspace/memory/YYYY-MM-DD.md`): "Bỏ qua cập nhật guide — thông báo <commonNotificationId>: <tóm tắt>"

## Bước 9: Cleanup — Dọn dẹp bảo trì hết hạn

Thực hiện **mỗi lần heartbeat hoặc MSC check** (kể cả khi đang skip do bảo trì):

### 9.1 Kiểm tra block hết hạn

Đọc `workspace/HEARTBEAT.md`, tìm tất cả block `## MSC Maintenance Pause`:
- Nếu thời gian hiện tại > End → block đã hết hạn

### 9.2 Xóa block hết hạn

- Xóa toàn bộ block `## MSC Maintenance Pause` đã hết hạn khỏi HEARTBEAT.md
- Giữ nguyên các nội dung khác trong HEARTBEAT.md

### 9.3 Thông báo cleanup

Sau khi xóa block hết hạn, thêm vào báo cáo Telegram:
```
Bảo trì MSC đã kết thúc, đã resume check tự động
```

## Output Format — Báo cáo Telegram

```
🏛️ **THÔNG BÁO MUA SẮM CÔNG**
📅 Cập nhật: {ngày giờ}
📡 Nguồn: API muasamcong.mpi.gov.vn

📋 **Thông báo hệ thống:**
1. 📌 {tiêu đề} — {ngày}
   {tóm tắt ngắn, max 2 dòng}
2. 📌 {tiêu đề} — {ngày}
   {tóm tắt ngắn}

🔧 **Lịch bảo trì:**
1. 🔧 {tiêu đề} — {ngày}
   {chi tiết bảo trì}

⚠️ **Hạn chế cạnh tranh:**
1. ⚠️ {tiêu đề} — {ngày}
   {tóm tắt}

🔗 Chi tiết: https://muasamcong.mpi.gov.vn/web/guest/thong-bao

🤖 **Hành động tự động:**
- ✅ Đã cập nhật HEARTBEAT.md — tạm dừng check MSC từ {Start} đến {End}
- ❓ Phát hiện thay đổi quy trình, chờ xác nhận cập nhật guide
```

### Quy tắc hiển thị section hành động

- **Chỉ có hành động tự động** (đã cập nhật HEARTBEAT.md): dùng header `🤖 **Hành động tự động:**`, hiển thị `✅ Đã cập nhật...`
- **Chỉ có hành động đề xuất** (phát hiện thay đổi quy trình, chờ user): dùng header `🤖 **Hành động đề xuất:**`, hiển thị `❓ Phát hiện thay đổi...`
- **Có cả hai**: dùng header `🤖 **Hành động tự động:**`, liệt kê cả `✅` và `❓` items
- **Không có hành động nào**: **KHÔNG hiển thị** section — bỏ qua hoàn toàn

Nếu không có thông báo mới → ghi rõ "Không có thông báo mới trong tuần qua."

## Fallback khi API fail

Nếu curl trả lỗi (timeout, 4xx, 5xx):

1. Thử lại 1 lần sau 5 giây
2. Nếu vẫn fail → dùng `web_search` với query: `"thông báo" site:muasamcong.mpi.gov.vn`
3. Dùng `web_fetch` GET `https://muasamcong.mpi.gov.vn/web/guest/thong-bao` để đọc HTML
4. Báo cho user: "API MSC không phản hồi, kết quả từ web search"

## Lưu kết quả

Sau khi hoàn thành, lưu vào `workspace/memory/`:

- File: `workspace/memory/msc-{YYYY-MM-DD}.md`
- Ghi: ngày kiểm tra, nguồn (API), danh sách thông báo theo loại
- Nếu file đã tồn tại → append section mới với timestamp

```markdown
# MSC Check — 2026-02-27

## 10:30 — Kiểm tra tuần
- Nguồn: API get-list
- Thông báo hệ thống: 3 mục
  1. ...
- Lịch bảo trì: 1 mục
  1. ...
- Hạn chế cạnh tranh: 0 mục
```