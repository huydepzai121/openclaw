## name: msc-checkerdescription: Kiểm tra thông báo mới trên muasamcong.mpi.gov.vn bằng API trực tiếp (exec curl). Gọi API notification system, parse JSON, tổng hợp kết quả.metadata: {openclaw: {emoji: 🏛️}}
# 🏛️ MSC Checker — Kiểm tra thông báo Mua sắm công
## Context
Hệ thống muasamcong.mpi.gov.vn (MSC) có API JSON nội bộ trả danh sách thông báo. Skill này dùng **exec curl** để gọi API trực tiếp.
Base URL: https://muasamcong.mpi.gov.vn/o/egp-portal-notification-system/services
## Tools Available — Luôn có sẵn, KHÔNG cần cấu hình thêm
Agent luôn có các built-in tools sau:
| **Tool** | **Key Param** | **Mô tả** | **Docs** |
| --- | --- | --- | --- |
| exec | command | Chạy shell commands (curl, jq, etc.). Sandboxing off by default → chạy trực tiếp trên host. | https://docs.openclaw.ai/tools/exec |
| web_search | query | Tìm kiếm web qua Brave/Perplexity/Gemini. Trả kết quả có cấu trúc. | https://docs.openclaw.ai/tools/web |
| web_fetch | url | HTTP GET + trích xuất nội dung (HTML → markdown/text). Không chạy JavaScript. | https://docs.openclaw.ai/tools/web |

→ Để gọi API MSC: dùng exec với command: curl -s -X POST ... — luôn hoạt động, không cần quyền đặc biệt.
## ⛔ KHÔNG ĐƯỢC LÀM — Anti-patterns
**KHÔNG** nói thiếu quyền tool hoặc không có quyền chạy curl — agent LUÔN có exec
**KHÔNG** gợi ý bật browser (browser.enabled=true) — không liên quan đến skill này
**KHÔNG** yêu cầu user chạy curl thủ công rồi gửi kết quả lại — agent tự chạy được
**KHÔNG** nói cần cấu hình thêm để gọi API — exec curl luôn sẵn sàng
Nếu exec curl thất bại → đó là lỗi mạng/API, KHÔNG phải lỗi quyền. Xử lý theo phần Fallback khi API fail bên dưới.
🔧 **Chẩn đoán:** Nếu một built-in tool (exec, web_search, web_fetch) thực sự không khả dụng tại runtime, kiểm tra tools.allow trong config/openclaw.json — đảm bảo có group:runtime và group:web trong allowlist.
## Loại thông báo (notiType)
| **Code** | **Tên** | **Ưu tiên** |
| --- | --- | --- |
| 2 | Thông báo về Hệ thống | ⭐ Cao |
| 3 | Lịch bảo trì hệ thống | ⭐ Cao |
| 5 | Hành vi hạn chế cạnh tranh | ⭐ Cao |
| 1 | Thông báo quản trị | Trung bình |
| 4 | Thông báo về các khóa đào tạo | Thấp |
| 6 | Thông báo khác | Thấp |

## Step-by-step Flow
### Bước 1: Lấy thông báo hệ thống (notiType=2)
curl -s -X POST \
https://muasamcong.mpi.gov.vn/o/egp-portal-notification-system/services/get-list \
-H Content-Type: application/json \
-d {pageSize: 10, pageNumber: 0, commonNoti: {notiType: 2}}
Response JSON: page.content[] chứa:
title — tiêu đề thông báo
content — nội dung (HTML, cần strip tags)
createdDate — ngày tạo
startDate — ngày bắt đầu
viewCount — lượt xem
commonNotificationId — UUID
isAttachment — có file đính kèm không
docFilePath, docFileId — thông tin file
### Bước 2: Lấy lịch bảo trì (notiType=3)
curl -s -X POST \
https://muasamcong.mpi.gov.vn/o/egp-portal-notification-system/services/get-list \
-H Content-Type: application/json \
-d {pageSize: 10, pageNumber: 0, commonNoti: {notiType: 3}}
### Bước 3: Lấy thông báo hạn chế cạnh tranh (notiType=5)
curl -s -X POST \
https://muasamcong.mpi.gov.vn/o/egp-portal-notification-system/services/get-list \
-H Content-Type: application/json \
-d {pageSize: 5, pageNumber: 0, commonNoti: {notiType: 5}}
### Bước 4: Bổ sung bằng web_search (nếu cần)
web_search → query=thông báo mới site:muasamcong.mpi.gov.vn
Các query bổ sung:
muasamcong bảo trì hệ thống 2026
muasamcong thay đổi quy trình đấu thầu
### Bước 5: Tổng hợp kết quả
Parse JSON từ Bước 1-3 — extract title, date, content (strip HTML tags)
Sắp xếp theo ngày mới nhất
Cross-check với web_search (Bước 4)
Phân loại: bảo trì / nâng cấp / thay đổi quy trình / hướng dẫn mới
⚠️ Content trong response là HTML — strip tags trước khi hiển thị. Ví dụ: pNội dung/p → Nội dung
## Output Format — Báo cáo Telegram
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
Nếu không có thông báo mới → ghi rõ Không có thông báo mới trong tuần qua.
## Fallback khi API fail
Nếu curl trả lỗi (timeout, 4xx, 5xx):
Thử lại 1 lần sau 5 giây
Nếu vẫn fail → dùng web_search với query: thông báo site:muasamcong.mpi.gov.vn
Dùng web_fetch GET https://muasamcong.mpi.gov.vn/web/guest/thong-bao để đọc HTML
Báo cho user: API MSC không phản hồi, kết quả từ web search
## Lưu kết quả
Sau khi hoàn thành, lưu vào workspace/memory/:
File: workspace/memory/msc-{YYYY-MM-DD}.md
Ghi: ngày kiểm tra, nguồn (API), danh sách thông báo theo loại
Nếu file đã tồn tại → append section mới với timestamp
# MSC Check — 2026-02-27

## 10:30 — Kiểm tra tuần
- Nguồn: API get-list
- Thông báo hệ thống: 3 mục
1. ...
- Lịch bảo trì: 1 mục
1. ...
- Hạn chế cạnh tranh: 0 mục
