// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Objective42",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "Objective42",
            targets: ["Objective42"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Objective42",
            dependencies: [],
            path: "Sources/Objective42",
            publicHeadersPath: "Include",
            cSettings: [
                .define("DEBUG", to: "1", .when(configuration: .debug)),
            ]
        ),
    ]
)
