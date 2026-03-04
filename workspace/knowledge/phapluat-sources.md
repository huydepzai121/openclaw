# Nguồn văn bản pháp luật Việt Nam

## QUAN TRỌNG: Quy tắc khi rà soát

- Luôn ghi rõ: **số hiệu**, **ngày ban hành**, **cơ quan ban hành**
- So sánh **ĐIỂM MỚI** vs quy định cũ khi có thay đổi
- Ưu tiên nguồn chính thống (vanban.chinhphu.vn, congbao.chinhphu.vn)
- Ghi link gốc đến văn bản

## Nguồn tin đáng tin cậy

| Nguồn | URL | Mô tả |
| --- | --- | --- |
| Cổng thông tin Chính phủ | https://vanban.chinhphu.vn | Văn bản do Chính phủ ban hành |
| Công báo Chính phủ | https://congbao.chinhphu.vn | Công báo chính thức |
| Thư viện pháp luật | https://thuvienphapluat.vn | Tra cứu tổng hợp, tốt nhất |
| Luật Việt Nam | https://luatvietnam.vn | Tra cứu + phân tích |
| CSDL quốc gia VBPL | https://vbpl.vn | Cơ sở dữ liệu quốc gia |
| Bộ Tư pháp | https://moj.gov.vn | Văn bản Bộ Tư pháp |
| Quốc hội | https://quochoi.vn | Luật, Nghị quyết QH |

## Hệ thống cấp bậc văn bản pháp luật VN

1. **Hiến pháp** — cao nhất
2. **Luật / Bộ luật** — do Quốc hội ban hành
3. **Nghị quyết của Quốc hội**
4. **Pháp lệnh** — do Ủy ban Thường vụ QH ban hành
5. **Nghị định** — do Chính phủ ban hành (hướng dẫn thi hành Luật)
6. **Quyết định của Thủ tướng**
7. **Thông tư** — do Bộ trưởng ban hành (hướng dẫn chi tiết)
8. **Thông tư liên tịch** — do nhiều Bộ phối hợp
9. **Chỉ thị** — chỉ đạo thực hiện

## Cách search hiệu quả

- Search theo site: `"nghị định mới 2026" site:vanban.chinhphu.vn`
- Search theo site: `"thông tư" site:thuvienphapluat.vn`
- Search tổng hợp: `văn bản pháp luật mới ban hành tuần này Việt Nam`
- Search theo lĩnh vực: `nghị định thuế mới 2026`, `thông tư lao động mới`

## Các lĩnh vực cần theo dõi — Domain Keywords (dùng bởi skill vbpl-reviewer)

| Emoji | Lĩnh vực | Keywords (case-insensitive) |
|-------|----------|----------------------------|
| 🏗️ | Đấu thầu, Đầu tư công | đấu thầu, mua sắm công, đầu tư công, lựa chọn nhà thầu |
| 💰 | Thuế, Tài chính | thuế, ngân sách, tài chính, kế toán, kiểm toán, phí, lệ phí |
| 🏢 | Doanh nghiệp, Đầu tư | doanh nghiệp, đầu tư, đăng ký kinh doanh, cổ phần, vốn |
| 👷 | Lao động, BHXH | lao động, bảo hiểm xã hội, tiền lương, việc làm, an toàn lao động |
| 🏠 | BĐS, Xây dựng | đất đai, bất động sản, xây dựng, nhà ở, quy hoạch |
| 📈 | Chứng khoán, Ngân hàng | chứng khoán, ngân hàng, tín dụng, lãi suất, bảo hiểm |
| 💻 | CNTT, An ninh mạng | công nghệ thông tin, an ninh mạng, dữ liệu, chuyển đổi số, viễn thông |
| 🌍 | Thương mại QT, Hải quan | xuất khẩu, nhập khẩu, hải quan, thương mại, thuế quan, FTA |
| 📋 | Khác | (không match keyword nào ở trên) |

## Regex — Nhận dạng số hiệu văn bản (dùng bởi skill vbpl-reviewer để dedup)

```
Luật:           Luật số \d+/\d{4}/QH\d+
Nghị quyết QH:  \d+/\d{4}/NQ-QH\d+
                \d+/NQ-QH\d+
Nghị quyết CP:  \d+/\d{4}/NQ-CP
Nghị định:      \d+/\d{4}/NĐ-CP
Quyết định TTg: \d+/\d{4}/QĐ-TTg
Thông tư:       \d+/\d{4}/TT-[A-ZĐ]+
Thông tư LT:    \d+/\d{4}/TTLT-[A-ZĐ\-]+
Pháp lệnh:     \d+/\d{4}/PL-UBTVQH\d+
Chỉ thị:       \d+/CT-TTg
```

> Normalize trước khi so sánh: lowercase, bỏ khoảng trắng thừa, chuẩn hóa dấu `/`.

## Văn bản quan trọng gần đây (cập nhật thường xuyên)

- Luật Đấu thầu 2023 (Luật số 22/2023/QH15) — có hiệu lực 01/01/2024
- Nghị định 24/2024/NĐ-CP — hướng dẫn Luật Đấu thầu
- Luật Đất đai 2024 (Luật số 31/2024/QH15) — có hiệu lực 01/08/2024
- Luật Nhà ở 2023 (Luật số 27/2023/QH15)
- Luật Kinh doanh BĐS 2023 (Luật số 29/2023/QH15)
