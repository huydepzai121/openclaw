# Hệ thống Mua sắm công Việt Nam

## QUAN TRỌNG: Quy tắc khi rà soát

- Khi có thay đổi quy trình → **so sánh cũ vs mới**, highlight điểm khác biệt
- Ghi rõ **ngày** và **nguồn** cho mỗi thông tin
- Ưu tiên thông tin từ muasamcong.mpi.gov.vn (nguồn chính thức)

## Giới thiệu

Hệ thống mua sắm công (muasamcong.mpi.gov.vn) là hệ thống đấu thầu điện tử quốc gia do Bộ Kế hoạch và Đầu tư quản lý. Tất cả gói thầu sử dụng vốn nhà nước phải đăng tải trên hệ thống này.

## URLs quan trọng

| Trang | URL | Mô tả |
| --- | --- | --- |
| Trang chủ | https://muasamcong.mpi.gov.vn | Portal chính |
| Thông báo | https://muasamcong.mpi.gov.vn/web/guest/thong-bao | Thông báo hệ thống |
| Hướng dẫn | https://muasamcong.mpi.gov.vn/web/guest/huong-dan | Hướng dẫn sử dụng |
| Tra cứu gói thầu | https://muasamcong.mpi.gov.vn/web/guest/contractor-selection | Tìm gói thầu |
| Đăng ký nhà thầu | https://muasamcong.mpi.gov.vn/web/guest/dang-ky | Đăng ký tài khoản |

## Các loại thông báo cần theo dõi

1. **Bảo trì hệ thống** — lịch bảo trì, downtime
2. **Nâng cấp hệ thống** — tính năng mới, thay đổi giao diện
3. **Thay đổi quy trình** — quy trình đấu thầu, nộp hồ sơ, đánh giá
4. **Hướng dẫn mới** — cho nhà thầu, bên mời thầu, cơ quan quản lý
5. **Văn bản pháp luật** — nghị định, thông tư liên quan đấu thầu

## Luật nền tảng

### Luật Đấu thầu 2023 (Luật số 22/2023/QH15)
- Có hiệu lực: 01/01/2024
- Thay thế: Luật Đấu thầu 2013
- Điểm mới chính:
  - Mở rộng phạm vi áp dụng
  - Đẩy mạnh đấu thầu qua mạng
  - Quy định mới về ưu đãi trong đấu thầu
  - Tăng cường minh bạch, chống thông thầu

### Nghị định 24/2024/NĐ-CP
- Hướng dẫn thi hành Luật Đấu thầu 2023
- Quy định chi tiết về:
  - Lựa chọn nhà thầu
  - Hồ sơ mời thầu
  - Đánh giá hồ sơ dự thầu
  - Đấu thầu qua mạng

## Quy trình đấu thầu cơ bản

1. Lập kế hoạch lựa chọn nhà thầu
2. Phê duyệt kế hoạch
3. Đăng tải thông tin gói thầu trên muasamcong
4. Phát hành hồ sơ mời thầu
5. Nhà thầu nộp hồ sơ dự thầu (qua mạng)
6. Mở thầu
7. Đánh giá hồ sơ dự thầu
8. Thẩm định kết quả
9. Phê duyệt kết quả lựa chọn nhà thầu
10. Thông báo kết quả + ký hợp đồng

## Cách search thông tin MSC

- Search: `"thông báo" site:muasamcong.mpi.gov.vn`
- Search: `muasamcong thay đổi quy trình 2026`
- Search: `hệ thống đấu thầu điện tử thông báo mới`
- Search: `nghị định đấu thầu mới nhất`

## Browser Automation — Hướng dẫn cho Agent

### Browser tool actions

| Action | Mô tả |
| --- | --- |
| `status` | Kiểm tra browser đang chạy hay không |
| `start` | Khởi động browser |
| `stop` | Tắt browser |
| `snapshot` | Chụp DOM snapshot (mode: `ai` hoặc `aria`), trả về refs |
| `screenshot` | Chụp ảnh màn hình (returns image block + `MEDIA:<path>`) |
| `act` | UI actions: click/type/press/hover/drag/select/fill/resize/wait/evaluate |
| `navigate` | Điều hướng đến URL |
| `open` | Mở tab mới với URL |
| `tabs` | Liệt kê các tabs đang mở |

### Recommended flow (PHẢI FOLLOW)

```
1. browser → status          # kiểm tra browser đang chạy
2. browser → start           # nếu chưa chạy
3. browser → open            # url=https://muasamcong.mpi.gov.vn/web/guest/home
4. browser → snapshot        # mode=ai → đọc page content, lấy refs
5. browser → act             # action=click ref=<số> (nếu cần click popup/button)
6. browser → screenshot      # nếu cần visual confirmation
```

### Lưu ý quan trọng

- `act` cần `ref` từ `snapshot` — **KHÔNG dùng CSS selector trực tiếp** (trừ `evaluate`)
- `snapshot` mặc định dùng mode `ai` khi Playwright installed
- Tránh `act → wait` mặc định; chỉ dùng khi không có UI state đáng tin cậy
- MSC dùng **Liferay Portal + Vue.js** — popup load bằng JS, cần đợi render
- Sau mỗi navigation hoặc click quan trọng, chạy `snapshot` lại để lấy refs mới

### Backup plan nếu browser fail

Nếu browser không khả dụng hoặc gặp lỗi:

- **API endpoint:** `POST /o/egp-portal-notification-system/services/get-list`
- Dùng `web_fetch` hoặc `exec` curl để gọi API trực tiếp
