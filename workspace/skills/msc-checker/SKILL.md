---
name: msc-checker
description: Kiểm tra thông báo mới trên muasamcong.mpi.gov.vn bằng MCP tools (web_fetch, web_search, exec curl). Gọi API trực tiếp, fetch trang thông báo, và tổng hợp kết quả.
metadata: {"openclaw": {"emoji": "🏛️"}}
---

# 🏛️ MSC Checker — Kiểm tra thông báo Mua sắm công

## Context

Hệ thống muasamcong.mpi.gov.vn (MSC) có API JSON trả danh sách thông báo hệ thống. Skill này dùng **MCP tools** (`web_fetch`, `web_search`, `exec curl`) — không cần browser.

Chiến lược: API trước, web_fetch HTML sau, web_search bổ sung.

## Step-by-step Flow

### Bước 1: Gọi API lấy danh sách thông báo

Dùng `exec` để gọi API trực tiếp:

```bash
curl -s -X POST \
  'https://muasamcong.mpi.gov.vn/o/egp-portal-notification-system/services/get-list' \
  -H 'Content-Type: application/json' \
  -d '{"page": 1, "pageSize": 10}'
```

Response là JSON chứa danh sách thông báo. Extract:
- Tiêu đề thông báo
- Ngày đăng
- Nội dung tóm tắt
- Phân loại: bảo trì / nâng cấp / thay đổi quy trình / hướng dẫn mới

> ⚠️ Nếu API trả lỗi hoặc yêu cầu auth → chuyển Bước 2.

### Bước 2: Fetch trang thông báo bằng web_fetch

Nếu API fail, dùng `web_fetch` để đọc HTML trang thông báo:

```
web_fetch → url=https://muasamcong.mpi.gov.vn/web/guest/thong-bao
```

Đọc HTML trả về, tìm:
- Danh sách thông báo trong DOM (thường nằm trong `<div>` hoặc `<table>`)
- Tiêu đề, ngày, link chi tiết

Nếu trang thông báo không có data (do JS render) → chuyển Bước 3.

### Bước 3: Fetch trang chủ MSC

```
web_fetch → url=https://muasamcong.mpi.gov.vn/web/guest/home
```

Đọc HTML trang chủ, tìm:
- Banner thông báo hệ thống
- Link đến thông báo mới
- Nội dung tĩnh về bảo trì / nâng cấp

### Bước 4: Bổ sung bằng web_search

Dùng `web_search` để tìm thông báo mới nhất:

```
web_search → query="thông báo" site:muasamcong.mpi.gov.vn
```

Các query bổ sung nếu cần:
- `muasamcong bảo trì hệ thống 2026`
- `muasamcong thay đổi quy trình đấu thầu`
- `hệ thống đấu thầu điện tử thông báo mới`

### Bước 5: Tổng hợp kết quả

Gộp dữ liệu từ các bước trên:
1. Ưu tiên dữ liệu từ API (Bước 1) — chính xác nhất
2. Bổ sung từ web_fetch (Bước 2-3) — nếu API fail
3. Cross-check với web_search (Bước 4) — bắt thông tin bên ngoài MSC

## Output Format — Báo cáo Telegram

```
🏛️ **THÔNG BÁO MUA SẮM CÔNG**
📅 Cập nhật: {ngày giờ}
📡 Nguồn: {API / web_fetch / web_search}

📋 **Danh sách thông báo gần đây:**
1. 📌 {tiêu đề} — {ngày}
   {tóm tắt ngắn}
2. 📌 {tiêu đề} — {ngày}
   {tóm tắt ngắn}
...

🔗 Chi tiết: https://muasamcong.mpi.gov.vn/web/guest/thong-bao
```

## Lưu kết quả

Sau khi hoàn thành, lưu kết quả vào `workspace/memory/`:

- File: `workspace/memory/msc-{YYYY-MM-DD}.md`
- Ghi: ngày kiểm tra, nguồn dữ liệu (API/fetch/search), danh sách thông báo
- Nếu file đã tồn tại (kiểm tra nhiều lần/ngày) → append thêm section mới với timestamp

Ví dụ:

```markdown
# MSC Check — 2026-02-23

## 10:30 — Lần kiểm tra 1
- Nguồn: API get-list
- Thông báo mới: 3 mục
  1. ...
```

