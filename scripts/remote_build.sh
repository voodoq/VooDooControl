#!/bin/bash
#
# remote_build.sh
# Trigger builds remotely on cloud Mac via SSH
# Run this from your local machine to control the cloud Mac
#

set -e

# Configuration - CHANGE THESE
CLOUD_MAC_IP="YOUR_CLOUD_MAC_IP"
CLOUD_MAC_USER="YOUR_USERNAME"
VOODOO_PATH="/Users/$CLOUD_MAC_USER/VooDooControl"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Parse arguments
COMMAND="${1:-status}"

echo "🎱 VooDoo Remote Build Controller"
echo "=================================="
echo ""

# Check SSH connection
echo "🔌 Connecting to cloud Mac at $CLOUD_MAC_IP..."
if ! ssh -o ConnectTimeout=5 "$CLOUD_MAC_USER@$CLOUD_MAC_IP" "echo 'Connected'" > /dev/null 2>&1; then
    echo "❌ Cannot connect to cloud Mac"
    echo "Make sure SSH is enabled: System Preferences → Sharing → Remote Login"
    exit 1
fi

echo -e "${GREEN}✅ Connected${NC}"
echo ""

# Execute command
case "$COMMAND" in
    status)
        echo "📊 Checking status..."
        ssh "$CLOUD_MAC_USER@$CLOUD_MAC_IP" "
            cd $VOODOO_PATH && \
            echo 'Current branch:' && \
            git branch --show-current && \
            echo '' && \
            echo 'Last commit:' && \
            git log -1 --oneline && \
            echo '' && \
            echo 'Build directory:' && \
            ls -lah build/ 2>/dev/null || echo 'No builds yet'
        "
        ;;
        
    pull)
        echo "📥 Pulling latest code..."
        ssh "$CLOUD_MAC_USER@$CLOUD_MAC_IP" "
            cd $VOODOO_PATH && \
            git pull origin main
        "
        echo -e "${GREEN}✅ Code updated${NC}"
        ;;
        
    build)
        echo "🔨 Starting debug build..."
        ssh "$CLOUD_MAC_USER@$CLOUD_MAC_IP" "
            cd $VOODOO_PATH && \
            ./scripts/build.sh debug 2>&1
        "
        ;;
        
    test)
        echo "🧪 Running tests..."
        ssh "$CLOUD_MAC_USER@$CLOUD_MAC_IP" "
            cd $VOODOO_PATH && \
            ./scripts/build.sh test 2>&1
        "
        ;;
        
    release)
        echo "📦 Building release..."
        ssh "$CLOUD_MAC_USER@$CLOUD_MAC_IP" "
            cd $VOODOO_PATH && \
            ./scripts/build.sh release 2>&1
        "
        ;;
        
    deploy)
        echo "🚀 Deploying to TestFlight..."
        ssh "$CLOUD_MAC_USER@$CLOUD_MAC_IP" "
            cd $VOODOO_PATH && \
            fastlane beta 2>&1
        "
        ;;
        
    logs)
        echo "📜 Showing recent build logs..."
        ssh "$CLOUD_MAC_USER@$CLOUD_MAC_IP" "
            cd $VOODOO_PATH && \
            tail -n 100 build/build.log 2>/dev/null || echo 'No logs found'
        "
        ;;
        
    download)
        echo "📥 Downloading latest build..."
        mkdir -p ./downloads
        scp -r "$CLOUD_MAC_USER@$CLOUD_MAC_IP:$VOODOO_PATH/build/*.app" ./downloads/ 2>/dev/null || \
        scp -r "$CLOUD_MAC_USER@$CLOUD_MAC_IP:$VOODOO_PATH/build/" ./downloads/
        echo -e "${GREEN}✅ Downloaded to ./downloads/${NC}"
        ;;
        
    shell)
        echo "🔓 Opening remote shell..."
        ssh "$CLOUD_MAC_USER@$CLOUD_MAC_IP" -t "cd $VOODOO_PATH && bash"
        ;;
        
    *)
        echo "VooDoo Remote Build Controller"
        echo ""
        echo "Usage: ./remote_build.sh [command]"
        echo ""
        echo "Commands:"
        echo "  status    - Show git status and build info"
        echo "  pull      - Pull latest code from GitHub"
        echo "  build     - Build debug version"
        echo "  test      - Run unit tests"
        echo "  release   - Build release archive"
        echo "  deploy    - Deploy to TestFlight"
        echo "  logs      - Show build logs"
        echo "  download  - Download build artifacts"
        echo "  shell     - Open remote shell"
        echo ""
        echo "Setup:"
        echo "  1. Edit this file and set CLOUD_MAC_IP and CLOUD_MAC_USER"
        echo "  2. Ensure SSH key is added to cloud Mac"
        echo "  3. Run: ./remote_build.sh status"
        ;;
esac
