---
name: vbpl-reviewer
description: Rà soát văn bản pháp luật mới ban hành hàng tuần từ CSDL quốc gia (vbpl.vn) và các nguồn chính thống. Dùng web_search + web_fetch, tổng hợp báo cáo Telegram.
metadata: {"openclaw": {"emoji": "⚖️"}}
---

# ⚖️ VBPL Reviewer — Rà soát văn bản pháp luật hàng tuần

## Context

Các cổng thông tin pháp luật VN (vbpl.vn, vanban.chinhphu.vn, congbao.chinhphu.vn) không có public REST API. vbpl.vn dùng SharePoint với AJAX endpoints nội bộ, WebService API (ws.vbpl.vn) cần tài khoản cơ quan. Skill này dùng **web_search** + **web_fetch** để quét và tổng hợp văn bản mới.

Tham khảo: `workspace/knowledge/phapluat-sources.md` — danh sách nguồn, hệ thống cấp bậc, keyword lĩnh vực.

## Tools Available — Luôn có sẵn, KHÔNG cần cấu hình thêm

| Tool | Key Param | Mô tả |
|------|-----------|-------|
| `web_search` | `query` | Tìm kiếm web qua Brave Search. Trả kết quả có cấu trúc. |
| `web_fetch` | `url` | HTTP GET + trích xuất nội dung (HTML → markdown/text). Không chạy JavaScript. |

> 🔧 Nếu tool không khả dụng tại runtime, kiểm tra `tools.allow` trong `config/openclaw.json` — đảm bảo có `group:web`.

## ⛔ KHÔNG ĐƯỢC LÀM — Anti-patterns

- **KHÔNG** nói "không thể truy cập trang web" — `web_search` và `web_fetch` luôn sẵn sàng
- **KHÔNG** gợi ý user tự search rồi gửi kết quả lại — agent tự làm được
- **KHÔNG** dùng `exec curl` để gọi vbpl.vn — trang dùng JS rendering, curl không lấy được nội dung
- **KHÔNG** bao gồm văn bản địa phương (UBND tỉnh/thành) — chỉ Trung ương
- **KHÔNG** phân tích/diễn giải nội dung pháp luật — chỉ tổng hợp và báo cáo

## Nguồn dữ liệu (theo thứ tự ưu tiên)

| # | Nguồn | URL | Ưu tiên |
|---|-------|-----|---------|
| 1 | CSDL quốc gia VBPL | vbpl.vn | ⭐ Cao nhất — nguồn chính thống |
| 2 | Cổng thông tin Chính phủ | vanban.chinhphu.vn | ⭐ Cao |
| 3 | Công báo Chính phủ | congbao.chinhphu.vn | ⭐ Cao |
| 4 | Thư viện pháp luật | thuvienphapluat.vn | Trung bình — tốt cho tóm tắt |

Khi cùng một văn bản xuất hiện ở nhiều nguồn → ưu tiên metadata từ nguồn có thứ tự cao hơn.

## Step-by-step Flow

### Bước 0: Kiểm tra dedup — Đọc memory tuần trước

Đọc các file `workspace/memory/vbpl-*.md` gần nhất (1-2 tuần) để lấy danh sách số hiệu đã báo cáo.

### Bước 1: Search văn bản mới theo loại

Chạy **web_search** với các query sau (thay `{YYYY}` bằng năm hiện tại):

**Query nhóm 1 — Luật & Nghị quyết QH:**
```
"luật mới" OR "bộ luật" OR "nghị quyết quốc hội" {YYYY} site:vbpl.vn
"luật" OR "nghị quyết" ban hành {YYYY} site:vanban.chinhphu.vn
```

**Query nhóm 2 — Nghị định:**
```
"nghị định" mới ban hành {YYYY} site:vbpl.vn
"nghị định" {YYYY} site:vanban.chinhphu.vn
```

**Query nhóm 3 — Quyết định TTg:**
```
"quyết định" "thủ tướng" {YYYY} site:vbpl.vn
"quyết định" "thủ tướng" {YYYY} site:vanban.chinhphu.vn
```

**Query nhóm 4 — Thông tư:**
```
"thông tư" mới ban hành {YYYY} site:vbpl.vn
"thông tư" mới {YYYY} site:thuvienphapluat.vn
```

**Query nhóm 5 — Tổng hợp (cross-check):**
```
văn bản pháp luật mới ban hành tuần này {YYYY} site:thuvienphapluat.vn
văn bản quy phạm pháp luật mới {YYYY} site:congbao.chinhphu.vn
```

> ⚠️ **Rate limit Brave Search:** Nếu nhận 429 → chờ 2 giây rồi retry, tối đa 3 lần/query. Country code dùng `ALL` (không dùng `VN` — trả 422).

### Bước 2: Lọc kết quả — Chỉ Trung ương

Từ kết quả search, **loại bỏ** các văn bản có dấu hiệu địa phương:
- Cơ quan ban hành là UBND tỉnh/thành/huyện/xã
- Số hiệu chứa `/QĐ-UBND`, `/NQ-HĐND`
- Title chứa tên tỉnh/thành cụ thể + "UBND" hoặc "HĐND"

**Giữ lại** văn bản từ:
- Quốc hội, Ủy ban Thường vụ QH
- Chính phủ, Thủ tướng Chính phủ
- Các Bộ, cơ quan ngang Bộ
- Tòa án nhân dân tối cao, Viện kiểm sát nhân dân tối cao

### Bước 3: Trích xuất metadata

Từ mỗi kết quả search, extract:

| Trường | Cách lấy | Bắt buộc |
|--------|----------|----------|
| Số hiệu | Regex từ title/snippet (xem phần Regex bên dưới) | ✅ |
| Loại văn bản | Từ prefix số hiệu (NĐ-CP → Nghị định, TT-BXX → Thông tư, etc.) | ✅ |
| Cơ quan ban hành | Từ suffix số hiệu hoặc snippet context | ✅ |
| Ngày ban hành | Từ snippet hoặc web_fetch detail page | Nếu có |
| Trích yếu | Từ title/snippet | ✅ |
| Ngày có hiệu lực | Từ web_fetch detail page | Nếu có |
| Link gốc | URL từ search result | ✅ |

### Bước 4: web_fetch chi tiết (khi cần)

Nếu search snippet thiếu thông tin (ngày ban hành, ngày hiệu lực), dùng **web_fetch** để lấy thêm:

```
web_fetch → url: "https://vbpl.vn/.../vbpq-toanvan.aspx?ItemID=..."
```

Hoặc:
```
web_fetch → url: "https://thuvienphapluat.vn/van-ban/..."
```

> ⚠️ Nếu web_fetch fail (timeout, empty) → dùng thông tin đã có từ search snippet, ghi chú "thiếu dữ liệu chi tiết".

### Bước 5: Dedup

1. **Dedup trong tuần**: Normalize số hiệu (lowercase, bỏ khoảng trắng thừa), so sánh. Cùng số hiệu từ nhiều nguồn → merge, ưu tiên metadata từ nguồn cao hơn.
2. **Dedup với tuần trước**: So sánh với danh sách số hiệu trong `workspace/memory/vbpl-*.md` gần nhất. Nếu đã báo cáo → bỏ qua, TRỪ KHI có thông tin mới (ví dụ: ngày hiệu lực mới công bố).

### Bước 6: Phân loại lĩnh vực

Gán mỗi văn bản vào 1+ lĩnh vực dựa trên keyword matching trong title + trích yếu:

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
| 📋 | Khác | Không match keyword nào ở trên |

> Agent có thể dùng kiến thức chung để bổ sung phân loại ngoài keyword matching, nhưng keyword là tiêu chí chính.

### Bước 7: Kiểm tra hiệu lực sắp tới

Với mỗi văn bản có ngày hiệu lực:
- Nếu ngày hiệu lực trong vòng 30 ngày tới → thêm annotation `⏰ Có hiệu lực: DD/MM/YYYY`
- Nếu không có ngày hiệu lực → bỏ qua annotation (không ghi placeholder)

## Regex — Nhận dạng số hiệu văn bản

Các pattern phổ biến (tham khảo `workspace/knowledge/phapluat-sources.md`):

```
Luật:           Luật số \d+/\d{4}/QH\d+
Nghị quyết QH:  \d+/\d{4}/NQ-QH\d+
                \d+/NQ-QH\d+
Nghị quyết CP:  \d+/\d{4}/NQ-CP
Nghị định:      \d+/\d{4}/NĐ-CP
Quyết định TTg: \d+/\d{4}/QĐ-TTg
Thông tư:       \d+/\d{4}/TT-[A-ZĐ]+
Thông tư LT:    \d+/\d{4}/TTLT-[A-ZĐ\-]+
```

## Output Format — Báo cáo Telegram

```
⚖️ **RÀ SOÁT VĂN BẢN PHÁP LUẬT TUẦN**
📅 Tuần {DD/MM} — {DD/MM/YYYY}
📡 Nguồn: vbpl.vn, vanban.chinhphu.vn, congbao.chinhphu.vn, thuvienphapluat.vn

📜 **Luật / Bộ luật:**
1. {emoji} **{số hiệu}** — {cơ quan ban hành} — {DD/MM/YYYY}
   {trích yếu, max 2 dòng}
   ⏰ Có hiệu lực: {DD/MM/YYYY}
   🔗 {link}

📋 **Nghị quyết QH:**
1. {emoji} **{số hiệu}** — ...

📑 **Nghị định:**
1. {emoji} **{số hiệu}** — ...

📝 **Quyết định TTg:**
1. {emoji} **{số hiệu}** — ...

📄 **Thông tư:**
1. {emoji} **{số hiệu}** — ...

📎 **Thông tư liên tịch:**
1. {emoji} **{số hiệu}** — ...

---
📊 **Tổng kết:** {N} văn bản mới ({X} Nghị định, {Y} Thông tư, ...) | {M} văn bản sắp có hiệu lực trong 30 ngày
```

### Quy tắc hiển thị

- **Section trống** (không có văn bản loại đó) → **bỏ qua hoàn toàn**, không hiển thị
- **Thứ tự section**: Luật/Bộ luật → Nghị quyết QH → Nghị định → Quyết định TTg → Thông tư → Thông tư liên tịch
- **Không có văn bản mới** → gửi: "Không có văn bản pháp luật mới trong tuần qua."
- **Annotation ⏰** chỉ hiển thị khi có ngày hiệu lực trong 30 ngày tới

## Fallback khi search fail

1. Nếu web_search trả lỗi (429, timeout) → chờ 2s, retry tối đa 3 lần
2. Nếu vẫn fail → thử query khác (bỏ `site:` filter, search tổng hợp)
3. Nếu tất cả fail → báo user: "Không thể tìm kiếm văn bản pháp luật lúc này, sẽ thử lại sau."

## Lưu kết quả

Sau khi hoàn thành, lưu vào `workspace/memory/`:

- File: `workspace/memory/vbpl-{YYYY-MM-DD}.md`
- Nếu file đã tồn tại → append section mới với timestamp

```markdown
# VBPL Review — 2026-03-04

## 08:00 — Rà soát tuần
- Nguồn: web_search (vbpl.vn, vanban.chinhphu.vn, congbao.chinhphu.vn, thuvienphapluat.vn)
- Tổng: {N} văn bản mới
- Nghị định: {X} mục
  1. {số hiệu} — {trích yếu}
- Thông tư: {Y} mục
  1. {số hiệu} — {trích yếu}
- Sắp có hiệu lực (30 ngày): {M} mục
```

## Cron Setup

Để chạy tự động hàng tuần, thêm cron job:

```bash
docker compose exec openclaw openclaw cron add \
  --name "vbpl-weekly-review" \
  --cron "0 8 * * 1" \
  --tz "Asia/Ho_Chi_Minh" \
  --session isolated \
  --message "Chạy skill vbpl-reviewer: rà soát văn bản pháp luật mới trong tuần qua" \
  --announce \
  --channel telegram \
  --to "<CHAT_ID>"
```

> Thay `<CHAT_ID>` bằng Telegram chat ID thực tế. Cron chạy mỗi thứ Hai lúc 8:00 sáng ICT.

