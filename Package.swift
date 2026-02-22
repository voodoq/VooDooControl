// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "VooDooControl",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "VooDooControl",
            targets: ["VooDooControl"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "600.0.0"),
    ],
    targets: [
        .target(
            name: "VooDooControl",
            dependencies: [],
            path: ".",
            exclude: [
                "scripts",
                "fastlane",
                ".github",
                "Info.plist",
                "VooDooControl.entitlements",
                "generate_xcode_project.sh",
                "README.md",
                "CI_CD_SETUP.md",
                "ARCHITECTURE.md",
                ".gitignore"
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "VooDooControlTests",
            dependencies: ["VooDooControl"],
            path: "Tests"
        ),
    ]
)
