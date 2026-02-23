#!/bin/bash
# OpenClaw God Mode Setup Script
# Build and run the all-in-one container

set -e

echo "🦞 OpenClaw God Mode Setup"
echo "=========================="
echo ""

# Check for .env file
if [ ! -f .env ]; then
    echo "📋 Creating .env from template..."
    cp .env.example .env
    echo ""
    echo "⚠️  Please edit .env with your actual keys:"
    echo "   - ANTHROPIC_API_KEY (or OPENAI_API_KEY)"
    echo "   - TELEGRAM_BOT_TOKEN (from @BotFather)"
    echo ""
    echo "   nano .env"
    echo ""
    exit 1
fi

# Create workspace directory if it doesn't exist
mkdir -p workspace

# Build the God Mode image
echo "📦 Building God Mode image (this may take a while)..."
docker compose build

echo ""
echo "✅ Build complete!"
echo ""

# Start the container
echo "🚀 Starting OpenClaw God Mode..."
docker compose up -d

echo ""
echo "✅ OpenClaw God Mode is running!"
echo ""
echo "📱 Next steps:"
echo "   1. Message your Telegram bot"
echo "   2. Approve pairing:"
echo "      docker compose exec openclaw openclaw pairing approve telegram <CODE>"
echo ""
echo "📰 VN News Bot setup (3 cron jobs):"
echo "   After pairing, add these 3 cron jobs:"
echo ""
echo "   🌅 Tin sáng (7h):"
echo "   docker compose exec openclaw openclaw cron add \\"
echo "     --name \"Tin tức VN buổi sáng\" \\"
echo "     --cron \"0 7 * * *\" \\"
echo "     --tz \"Asia/Ho_Chi_Minh\" \\"
echo "     --session isolated \\"
echo "     --message \"Bạn là bot tổng hợp tin tức Việt Nam buổi sáng. Hãy search tin tức Việt Nam mới nhất từ đêm qua đến sáng nay. Chọn 5-7 tin nổi bật nhất, đa dạng chủ đề (chính trị, kinh tế, xã hội, công nghệ, thể thao). Với mỗi tin: viết tiêu đề + tóm tắt 2-3 câu + link gốc. Cuối cùng, lưu danh sách tin đã gửi vào file workspace/memory/news-\$(date +%Y-%m-%d).md. Format đẹp cho Telegram, dùng emoji phù hợp. Viết bằng tiếng Việt.\" \\"
echo "     --announce \\"
echo "     --channel telegram \\"
echo "     --to \"\${TELEGRAM_CHAT_ID}\""
echo ""
echo "   ☀️ Tin trưa (12h):"
echo "   docker compose exec openclaw openclaw cron add \\"
echo "     --name \"Tin tức VN buổi trưa\" \\"
echo "     --cron \"0 12 * * *\" \\"
echo "     --tz \"Asia/Ho_Chi_Minh\" \\"
echo "     --session isolated \\"
echo "     --message \"Bạn là bot cập nhật tin tức Việt Nam buổi trưa. Hãy search tin tức Việt Nam mới nhất trong buổi sáng hôm nay. Focus vào tin kinh tế, thị trường chứng khoán, bất động sản, và công nghệ. Chọn 4-5 tin quan trọng nhất. Với mỗi tin: viết tiêu đề + tóm tắt 2-3 câu + link gốc. Đọc file workspace/memory/news-\$(date +%Y-%m-%d).md nếu có để tránh gửi trùng tin sáng. Append tin mới vào file đó. Format đẹp cho Telegram, dùng emoji phù hợp. Viết bằng tiếng Việt.\" \\"
echo "     --announce \\"
echo "     --channel telegram \\"
echo "     --to \"\${TELEGRAM_CHAT_ID}\""
echo ""
echo "   🌙 Tin tối (19h):"
echo "   docker compose exec openclaw openclaw cron add \\"
echo "     --name \"Tin tức VN buổi tối\" \\"
echo "     --cron \"0 19 * * *\" \\"
echo "     --tz \"Asia/Ho_Chi_Minh\" \\"
echo "     --session isolated \\"
echo "     --message \"Bạn là bot tổng kết tin tức Việt Nam buổi tối. Hãy search tin tức Việt Nam nổi bật nhất trong ngày hôm nay. Tổng kết đa dạng: chính trị, kinh tế, xã hội, giải trí, thể thao, quốc tế liên quan VN. Chọn 5-7 tin hay nhất. Với mỗi tin: viết tiêu đề + tóm tắt 2-3 câu + link gốc. Đọc file workspace/memory/news-\$(date +%Y-%m-%d).md nếu có để tránh trùng tin sáng/trưa. Append tin mới vào file đó. Format đẹp cho Telegram, dùng emoji phù hợp. Viết bằng tiếng Việt.\" \\"
echo "     --announce \\"
echo "     --channel telegram \\"
echo "     --to \"\${TELEGRAM_CHAT_ID}\""
echo ""
echo "   ⚠️  Nhớ thay TELEGRAM_CHAT_ID trong .env (lấy từ @userinfobot trên Telegram)"
echo "   ⚠️  Nhớ điền BRAVE_API_KEY trong .env (đăng ký tại https://brave.com/search/api/)"
echo ""
echo "🔧 Custom provider:"
echo "   Nếu muốn dùng provider riêng, sửa trong config/openclaw.json:"
echo "   - models.providers.myprovider.baseUrl → URL API của bạn"
echo "   - models.providers.myprovider.models → model ID + tên"
echo "   - MYPROVIDER_API_KEY trong .env → API key"
echo ""
echo "🔧 Useful commands:"
echo "   docker compose logs -f          # View logs"
echo "   docker compose exec openclaw bash  # Shell into container"
echo "   docker compose down             # Stop"
echo "   docker compose restart          # Restart"
echo ""

