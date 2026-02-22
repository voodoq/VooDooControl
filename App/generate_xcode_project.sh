#!/bin/bash

# generate_xcode_project.sh
# Generates Xcode project for VooDoo Mission Control

echo "🎱 VooDoo Mission Control - Project Generator"
echo "============================================="
echo ""

# Check if we're in the right directory
if [ ! -f "VooDooControlApp.swift" ]; then
    echo "❌ Error: Run this script from the VooDooControl/App directory"
    exit 1
fi

cd ..

# Generate Xcode project using Swift Package Manager
echo "📦 Generating Xcode project..."

# Create a temporary Package.swift
cat > Package.swift << 'EOF'
// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "VooDooControl",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "VooDooControl",
            targets: ["VooDooControl"]
        ),
    ],
    targets: [
        .target(
            name: "VooDooControl",
            path: ".",
            exclude: ["generate_xcode_project.sh", "README.md", ".gitignore"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
    ]
)
EOF

# Generate Xcode project
swift package generate-xcodeproj

# Clean up temporary Package.swift
rm Package.swift

echo ""
echo "✅ Xcode project generated!"
echo ""
echo "Open VooDooControl.xcodeproj to get started"
echo ""
echo "Next steps:"
echo "1. Open VooDooControl.xcodeproj in Xcode"
echo "2. Select your development team"
echo "3. Build and run (⌘+R)"
echo ""
echo "🎱 VooDoo out."
