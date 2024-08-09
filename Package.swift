// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "JSONPreview",
    platforms: [
        .iOS(.v12),
        .tvOS(.v12),
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
            resources: [.process("./Resources/Assets.xcassets")]
        ),
        .testTarget(
            name: "JSONPreviewTests",
            dependencies: ["JSONPreview"],
            path: "Tests"
        ),
    ]
)

#if swift(>=5.6)
// Add the Rakuyo Swift formatting plugin if possible
package.dependencies.append(.package(url: "https://github.com/RakuyoKit/swift.git", from: "1.3.1"))
#endif
