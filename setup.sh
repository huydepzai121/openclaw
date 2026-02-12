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
echo "📰 VN News Bot setup:"
echo "   After pairing, add the cron job:"
echo ""
echo "   docker compose exec openclaw openclaw cron add \\"
echo "     --name \"Tin tức VN buổi sáng\" \\"
echo "     --cron \"0 0 * * *\" \\"
echo "     --tz \"Asia/Ho_Chi_Minh\" \\"
echo "     --session isolated \\"
echo "     --message \"Bạn là bot tổng hợp tin tức Việt Nam. Hãy tìm kiếm tin tức Việt Nam hôm nay từ nhiều nguồn (VnExpress, Tuổi Trẻ, CafeF, Thanh Niên). Chọn 5-7 tin thú vị nhất, đa dạng chủ đề (công nghệ, kinh tế, xã hội, thể thao). Với mỗi tin: viết tiêu đề + tóm tắt 2-3 câu + link gốc. Viết bằng tiếng Việt, format đẹp cho Telegram.\" \\"
echo "     --announce \\"
echo "     --channel telegram \\"
echo "     --to \"\${TELEGRAM_CHAT_ID}\""
echo ""
echo "   ⚠️  Nhớ thay TELEGRAM_CHAT_ID trong .env (lấy từ @userinfobot trên Telegram)"
echo "   ⚠️  Nhớ điền BRAVE_API_KEY trong .env (đăng ký tại https://brave.com/search/api/)"
echo ""
echo "   Cron chạy lúc 7h sáng (giờ VN) mỗi ngày."
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

