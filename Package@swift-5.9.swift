// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "JSONPreview",
    platforms: [
        .iOS(.v12),
        .tvOS(.v12),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "JSONPreview",
            targets: ["JSONPreview"]
        ),
    ],
    targets: [
        .target(
            name: "JSONPreview",
            path: "Sources",
            resources: [
                .copy("PrivacyInfo.xcprivacy"),
                .process("./Resources/Assets.xcassets"),
            ]
        ),
        .testTarget(
            name: "JSONPreviewTests",
            dependencies: ["JSONPreview"],
            path: "Tests"
        )
    ]
)

// Add the Swift formatting plugin
package.dependencies.append(.package(url: "https://github.com/RakuyoKit/swift.git", branch: "release/1.4.0"))
