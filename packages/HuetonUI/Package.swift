// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HuetonUI",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "HuetonUI",
            targets: ["HuetonUI"]
        ),
        .library(
            name: "SystemUI",
            targets: ["SystemUI"]
        ),
        .library(
            name: "DeclarativeUI",
            targets: ["DeclarativeUI"]
        ),
    ],
    dependencies: [
        .package(
            name: "GIEL",
            path: "../GIEL"
        ),
        .package(
            name: "Objective42",
            path: "../Objective42"
        ),
        .package(
            name: "Lottie",
            url: "https://github.com/airbnb/lottie-ios.git",
            from: "3.2.1"
        )
    ],
    targets: [
        .target(
            name: "HuetonUI",
            dependencies: [
                .product(name: "GIEL", package: "GIEL"),
                "Lottie",
                "SystemUI",
                "DeclarativeUI",
            ],
            path: "Sources/HuetonUI",
            exclude: [
                "3Party/Pinnable/LICENSE",
            ],
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
        .target(
            name: "SystemUI",
            dependencies: [
                "Objective42",
            ],
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
