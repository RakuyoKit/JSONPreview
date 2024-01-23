// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "JSONPreview",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "JSONPreview",
            targets: ["JSONPreview"]),
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
