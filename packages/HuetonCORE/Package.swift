// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HuetonCORE",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "HuetonCORE",
            targets: ["HuetonCORE"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "HuetonCORE",
            dependencies: [
            ],
            path: "Sources/HuetonCORE",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
            ]
        ),
    ]
)
