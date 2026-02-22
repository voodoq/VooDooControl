// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "VooDooControl",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .executable(
            name: "VooDooControl",
            targets: ["VooDooControl"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "VooDooControl",
            path: "."
        )
    ]
)
