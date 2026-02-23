---
name: msc-checker
description: Kiểm tra thông báo mới trên muasamcong.mpi.gov.vn bằng browser tool. Đọc popup thông báo, danh sách thông báo, và tổng hợp kết quả.
metadata: {"openclaw": {"requires": {"config": ["browser.enabled"]}, "emoji": "🏛️"}}
---

# 🏛️ MSC Checker — Kiểm tra thông báo Mua sắm công

## Context

Hệ thống muasamcong.mpi.gov.vn (MSC) chạy trên **Liferay Portal + Vue.js**. Popup thông báo được load bằng JavaScript sau khi trang render xong — không thể đọc bằng `web_fetch` thông thường. Cần dùng **browser tool** (headless Chromium) để:

- Đợi JS render popup
- Đọc nội dung popup thông báo
- Navigate đến trang danh sách thông báo
- Extract dữ liệu

## Step-by-step Flow

### Bước 1: Kiểm tra & khởi động browser

```
browser → status
```

Nếu browser chưa chạy:

```
browser → start
```

### Bước 2: Mở trang chủ MSC

```
browser → open url=https://muasamcong.mpi.gov.vn/web/guest/home
```

**Đợi 5 giây** để JS load xong (MSC cần thời gian render popup):

```
browser → act action=wait time=5000
```

### Bước 3: Đọc popup thông báo

```
browser → snapshot mode=ai
```

Đọc kỹ snapshot output:
- Tìm popup/modal/dialog chứa thông báo hệ thống
- Ghi lại nội dung thông báo (tiêu đề, nội dung, ngày)
- Nếu **KHÔNG thấy popup** → bỏ qua, chuyển Bước 5

### Bước 4: Xử lý popup (nếu có)

Đọc nội dung popup xong, đóng popup bằng cách click nút phù hợp:

```
browser → act action=click ref=<ref_number>
```

Tìm nút có text: **"Bỏ qua"**, **"Đã nhận thông tin"**, **"Đóng"**, hoặc **"×"**.

> ⚠️ `ref` lấy từ snapshot ở Bước 3 — KHÔNG dùng CSS selector.

### Bước 5: Navigate đến trang thông báo hệ thống

```
browser → navigate url=https://muasamcong.mpi.gov.vn/web/guest/notification-system
```

Đợi load:

```
browser → act action=wait time=3000
```

### Bước 6: Đọc danh sách thông báo

```
browser → snapshot mode=ai
```

Extract từ snapshot:
- Tiêu đề thông báo
- Ngày đăng
- Nội dung tóm tắt (nếu có)
- Phân loại: bảo trì / nâng cấp / thay đổi quy trình / hướng dẫn mới

### Bước 7: Chụp bằng chứng

```
browser → screenshot
```

Lưu screenshot path để đính kèm khi gửi báo cáo.

## Backup Plan — Khi browser không khả dụng

Nếu browser fail hoặc không available, thử gọi API trực tiếp:

```
POST https://muasamcong.mpi.gov.vn/o/egp-portal-notification-system/services/get-list
Content-Type: application/json

{
  "page": 1,
  "pageSize": 10
}
```

Dùng `web_fetch` hoặc `exec curl` để gọi. Response sẽ là JSON với danh sách thông báo.

> ⚠️ API có thể yêu cầu auth hoặc thay đổi — browser là phương án chính.

## Output Format — Báo cáo Telegram

```
🏛️ **THÔNG BÁO MUA SẮM CÔNG**
📅 Cập nhật: {ngày giờ}

📢 **Popup thông báo:**
{nội dung popup hoặc "Không có popup mới"}

📋 **Danh sách thông báo gần đây:**
1. 📌 {tiêu đề} — {ngày}
   {tóm tắt ngắn}
2. 📌 {tiêu đề} — {ngày}
   {tóm tắt ngắn}
...

🔗 Chi tiết: https://muasamcong.mpi.gov.vn/web/guest/notification-system
```

## Lưu kết quả

Sau khi hoàn thành, lưu kết quả vào `workspace/memory/`:

- File: `workspace/memory/msc-{YYYY-MM-DD}.md`
- Ghi: ngày kiểm tra, popup content, danh sách thông báo, screenshot path
- Nếu file đã tồn tại (kiểm tra nhiều lần/ngày) → append thêm section mới với timestamp

Ví dụ:

```markdown
# MSC Check — 2026-02-23

## 10:30 — Lần kiểm tra 1
- Popup: Thông báo bảo trì ngày 25/02
- Thông báo mới: 3 mục
  1. ...
- Screenshot: /path/to/screenshot.png
```

