// swift-tools-version: 5.8

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
            name: "ColorWellKit",
            resources: [
                .copy("Resources/ColorLists/DefaultColors.clr"),
                .copy("Resources/ColorLists/StandardColors.clr"),
            ]
        ),
        .testTarget(
            name: "ColorWellKitTests",
            dependencies: ["ColorWellKit"]
        ),
    ]
)
