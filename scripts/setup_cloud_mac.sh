#!/bin/bash
#
# setup_cloud_mac.sh
# Run this on your cloud Mac to prepare it for VooDoo builds
#

set -e

echo "🎱 VooDoo Cloud Mac Setup"
echo "=========================="
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script must run on macOS"
    exit 1
fi

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install dependencies
echo "📦 Installing dependencies..."
brew install git
brew install ruby
brew install swiftformat

# Install fastlane
echo "⚡ Installing fastlane..."
gem install fastlane

# Install Xcode Command Line Tools
echo "🛠️  Installing Xcode Command Line Tools..."
xcode-select --install 2>/dev/null || true

# Accept Xcode license
echo "📜 Accepting Xcode license..."
sudo xcodebuild -license accept 2>/dev/null || true

# Setup SSH key for GitHub
echo "🔑 Checking SSH keys..."
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "Generating SSH key..."
    ssh-keygen -t rsa -b 4096 -C "voodoo@control.ai" -N "" -f ~/.ssh/id_rsa
    echo "Add this key to GitHub:"
    cat ~/.ssh/id_rsa.pub
fi

# Clone VooDoo Control repo
echo "📂 Cloning VooDoo Control..."
if [ ! -d "~/VooDooControl" ]; then
    git clone git@github.com:yourusername/VooDooControl.git ~/VooDooControl
fi

cd ~/VooDooControl

# Setup git config
git config --global user.name "VooDoo CI"
git config --global user.email "voodoo@control.ai"

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Add your SSH key to GitHub"
echo "2. Configure fastlane match with your certificates"
echo "3. Run: ./scripts/build.sh"
