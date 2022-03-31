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
        .package(url: "https://github.com/hueton/SwiftyTON", branch: "main")
    ],
    targets: [
        .target(
            name: "HuetonCORE",
            dependencies: [
                "SwiftyTON",
            ],
            path: "Sources/HuetonCORE",
            resources: [
                .process("Resources/Model.xcdatamodeld")
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
            ]
        ),
    ]
)
