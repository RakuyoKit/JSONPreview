// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "JSONPreview",
    platforms: [
        .iOS(.v12),
        .tvOS(.v13),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "JSONPreview",
            targets: ["JSONPreview"]),
    ],
    targets: [
        .target(
            name: "JSONPreview",
            path: "Sources",
            resources: [.process("./Resources/Assets.xcassets")]),
        .testTarget(
            name: "JSONPreviewTests",
            dependencies: ["JSONPreview"],
            path: "Tests"),
    ]
)
