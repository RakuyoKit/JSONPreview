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

let swiftlintPlugin = Target.PluginUsage.plugin(name: "SwiftLintPlugin", package: "SwiftLint")

for i in package.targets.indices {
    if package.targets[i].plugins == nil {
        package.targets[i].plugins = [swiftlintPlugin]
    } else {
        package.targets[i].plugins?.append(swiftlintPlugin)
    }
}
