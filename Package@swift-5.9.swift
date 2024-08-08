// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "JSONPreview",
    platforms: [
        .iOS(.v12),
        .tvOS(.v12),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "JSONPreview",
            targets: ["JSONPreview"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/realm/SwiftLint.git",
            from: "0.54.0"),
    ],
    targets: [
        .target(
            name: "JSONPreview",
            resources: [
                .copy("PrivacyInfo.xcprivacy"),
                .process("./Resources/Assets.xcassets"),
            ]),
        .testTarget(
            name: "JSONPreviewTests",
            dependencies: ["JSONPreview"]),
    ]
)

// Add the Rakuyo Swift formatting plugin
package.dependencies.append(.package(url: "https://github.com/RakuyoKit/swift.git", from: "1.3.1"))
