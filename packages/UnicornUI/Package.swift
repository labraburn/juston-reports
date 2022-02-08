// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UnicornUI",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "UnicornUI",
            targets: ["UnicornUI"]
        ),
    ],
    dependencies: [
        .package(name: "Lottie", path: "../Lottie"),
    ],
    targets: [
        .target(
            name: "UnicornUI",
            dependencies: [
                .product(name: "Lottie", package: "Lottie"),
                "SystemUI",
                "DeclarativeUI",
            ],
            path: "Sources/UnicornUI",
            exclude: [
                "3Party/Pinnable/LICENSE",
            ],
            resources: [
                .copy("Resources/unicorn.svgp"),
                .copy("Resources/unicorn-loader.json"),
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
            ]
        ),
        .target(
            name: "SystemUI",
            dependencies: [],
            path: "Sources/SystemUI",
            publicHeadersPath: "Include",
            cSettings: [
                .define("DEBUG", to: "1", .when(configuration: .debug)),
            ]
        ),
        .target(
            name: "DeclarativeUI",
            dependencies: [],
            path: "Sources/DeclarativeUI",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
            ]
        ),
    ]
)
