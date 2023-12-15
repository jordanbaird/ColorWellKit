// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ColorWellKit",
    platforms: [
        .macOS(.v10_13),
    ],
    products: [
        .library(
            name: "ColorWellKit",
            targets: ["ColorWellKit"]
        ),
    ],
    targets: [
        .target(
            name: "ColorWellKit"
        ),
        .testTarget(
            name: "ColorWellKitTests",
            dependencies: ["ColorWellKit"]
        ),
    ]
)
