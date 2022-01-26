// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BilftUI",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "BilftUI",
            targets: ["BilftUI"]
        ),
    ],
    dependencies: [
        .package(
            name: "GIEL",
            path: "../GIEL"
        ),
    ],
    targets: [
        .target(
            name: "BilftUI",
            dependencies: [
                .product(name: "GIEL", package: "GIEL"),
            ],
            path: "Sources/BilftUI",
            resources: [
                .copy("Resources/Magic.fsh"),
                .copy("Resources/Magic.vsh"),
            ],
            cSettings: [
                .define("GLES_SILENCE_DEPRECATION", to: "1"),
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("GLES_SILENCE_DEPRECATION")
            ]
        ),
    ]
)
