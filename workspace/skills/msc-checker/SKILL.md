---
name: msc-checker
description: Kiểm tra thông báo mới trên muasamcong.mpi.gov.vn bằng API trực tiếp (exec curl). Gọi API notification system, parse JSON, tổng hợp kết quả.
metadata: {"openclaw": {"emoji": "🏛️"}}
---

# 🏛️ MSC Checker — Kiểm tra thông báo Mua sắm công

## Context

Hệ thống muasamcong.mpi.gov.vn (MSC) có API JSON nội bộ trả danh sách thông báo. Skill này dùng **exec curl** để gọi API trực tiếp — không cần browser, không cần MCP server.

Base URL: `https://muasamcong.mpi.gov.vn/o/egp-portal-notification-system/services`

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
```

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