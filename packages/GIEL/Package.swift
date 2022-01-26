// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GIEL",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "GIEL", targets: ["GIEL"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GIEL",
            dependencies: [],
            path: "Sources/GIEL",
            cSettings: [
                .define("GLES_SILENCE_DEPRECATION", to: "1"),
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("GLES_SILENCE_DEPRECATION")
            ]
        )
    ]
)
