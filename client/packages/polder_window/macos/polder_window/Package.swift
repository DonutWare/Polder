// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "polder_window",
    platforms: [
        .macOS("12.0")
    ],
    products: [
        .library(name: "polder-window", targets: ["polder_window"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "polder_window",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
