// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "JSONPreview",
    platforms: [.iOS(.v10)],
    products: [
        .library(name: "JSONPreview", targets: ["JSONPreview"]),
    ],
    targets: [
        .target(
            name: "JSONPreview",
            path: "JSONPreview",
            exclude: [
                "Other/AppDelegate.swift",
                "Other/ViewController.swift",
                "Other/Info.plist",
                "Other/Base.lproj",
            ],
            resources: [.process("Other/Assets.xcassets")]
        )
    ]
)
