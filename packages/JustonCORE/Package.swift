// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JustonCORE",
    platforms: [
        .iOS(.v13),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "JustonCORE",
            targets: ["JustonCORE"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/hueton/SwiftyTON",
            branch: "main"
        ),
        .package(
            name: "Objective42",
            path: "../Objective42"
        ),
    ],
    targets: [
        .target(
            name: "JustonCORE",
            dependencies: [
                "SwiftyTON",
                "Objective42",
            ],
            path: "Sources/JustonCORE",
            resources: [
                .process("Resources/Model.xcdatamodeld"),
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
            ]
        ),
    ]
)
