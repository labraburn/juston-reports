// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DefaultMOON",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "DefaultMOON",
            targets: ["DefaultMOON"]
        ),
    ],
    dependencies: [
        .package(
            name: "Objective42",
            path: "../Objective42"
        ),
        .package(
            name: "HuetonMOON",
            path: "../HuetonMOON"
        ),
    ],
    targets: [
        .target(
            name: "DefaultMOON",
            dependencies: [
                "Objective42",
                "HuetonMOON",
            ],
            path: "Sources/DefaultMOON",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
            ]
        ),
    ]
)
