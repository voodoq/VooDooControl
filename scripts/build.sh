#!/bin/bash
#
# build.sh
# Main build script - can be triggered remotely or by CI
#

set -e

echo "🎱 VooDoo Control Build System"
echo "==============================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="VooDooControl"
SCHEME="VooDooControl"
BUILD_DIR="build"

# Parse arguments
BUILD_TYPE="${1:-debug}"  # debug, release, or test
DESTINATION="${2:-iPhone 16 Pro}"

echo "📋 Build Configuration:"
echo "   Type: $BUILD_TYPE"
echo "   Destination: $DESTINATION"
echo ""

# Check prerequisites
echo "🔍 Checking prerequisites..."

if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ xcodebuild not found. Install Xcode.${NC}"
    exit 1
fi

if ! command -v fastlane &> /dev/null; then
    echo -e "${YELLOW}⚠️  fastlane not found. Install with: gem install fastlane${NC}"
fi

# Check for project
if [ ! -f "$PROJECT_NAME.xcodeproj/project.pbxproj" ]; then
    echo -e "${YELLOW}⚠️  Xcode project not found. Creating...${NC}"
    # Generate project if using Swift Package Manager
    if [ -f "Package.swift" ]; then
        swift package generate-xcodeproj
    else
        echo -e "${RED}❌ No project found and no Package.swift to generate from${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"
echo ""

# Create build directory
mkdir -p "$BUILD_DIR"

# Build based on type
case "$BUILD_TYPE" in
    debug)
        echo "🔨 Building Debug..."
        xcodebuild clean build \
            -project "$PROJECT_NAME.xcodeproj" \
            -scheme "$SCHEME" \
            -destination "platform=iOS Simulator,name=$DESTINATION" \
            -derivedDataPath "$BUILD_DIR/DerivedData" \
            CODE_SIGNING_REQUIRED=NO \
            CODE_SIGNING_ALLOWED=NO \
            | tee "$BUILD_DIR/build.log" \
            | xcpretty
        
        echo -e "${GREEN}✅ Debug build successful${NC}"
        ;;
        
    release)
        echo "🔨 Building Release..."
        
        # Check for signing
        if [ ! -f "fastlane/Matchfile" ]; then
            echo -e "${YELLOW}⚠️  No Matchfile found. Building unsigned...${NC}"
            SIGNING_FLAGS="CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO"
        else
            echo "🔐 Setting up code signing..."
            fastlane match appstore --readonly
            SIGNING_FLAGS=""
        fi
        
        xcodebuild clean archive \
            -project "$PROJECT_NAME.xcodeproj" \
            -scheme "$SCHEME" \
            -destination "generic/platform=iOS" \
            -archivePath "$BUILD_DIR/$PROJECT_NAME.xcarchive" \
            $SIGNING_FLAGS \
            | tee "$BUILD_DIR/build.log" \
            | xcpretty
        
        echo -e "${GREEN}✅ Archive successful${NC}"
        echo "📦 Archive: $BUILD_DIR/$PROJECT_NAME.xcarchive"
        ;;
        
    test)
        echo "🧪 Running Tests..."
        xcodebuild clean test \
            -project "$PROJECT_NAME.xcodeproj" \
            -scheme "$SCHEME" \
            -destination "platform=iOS Simulator,name=$DESTINATION" \
            -derivedDataPath "$BUILD_DIR/DerivedData" \
            CODE_SIGNING_REQUIRED=NO \
            CODE_SIGNING_ALLOWED=NO \
            | tee "$BUILD_DIR/test.log" \
            | xcpretty
        
        echo -e "${GREEN}✅ Tests passed${NC}"
        ;;
        
    *)
        echo -e "${RED}❌ Unknown build type: $BUILD_TYPE${NC}"
        echo "Usage: ./build.sh [debug|release|test] [destination]"
        exit 1
        ;;
esac

# Extract app for simulator testing
if [ "$BUILD_TYPE" == "debug" ]; then
    APP_PATH=$(find "$BUILD_DIR/DerivedData" -name "*.app" -type d | head -n 1)
    if [ -n "$APP_PATH" ]; then
        echo ""
        echo "📱 App location: $APP_PATH"
        
        # Copy to build directory for easy access
        cp -R "$APP_PATH" "$BUILD_DIR/"
        echo "📁 Copied to: $BUILD_DIR/$(basename $APP_PATH)"
    fi
fi

echo ""
echo "🎱 Build complete!"
echo "Logs: $BUILD_DIR/"
