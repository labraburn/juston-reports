// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JustonMOON",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "JustonMOON",
            targets: ["JustonMOON"]
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
            name: "JustonMOON",
            dependencies: [
                "Objective42",
            ],
            path: "Sources/JustonMOON",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
            ]
        ),
    ]
)
