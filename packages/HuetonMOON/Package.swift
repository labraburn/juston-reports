// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HuetonMOON",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "HuetonMOON",
            targets: ["HuetonMOON"]
        ),
    ],
    dependencies: [
        .package(
            name: "Objective42",
            path: "../Objective42"
        ),
    ],
    targets: [
        .target(
            name: "HuetonMOON",
            dependencies: [
                "Objective42",
            ],
            path: "Sources/HuetonMOON",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
            ]
        ),
    ]
)
