// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "ProcessOut",
    defaultLocalization: "en",
    platforms: [
        .iOS("11.1")
    ],
    products: [
        .library(name: "ProcessOut", targets: ["ProcessOut"]),
    ],
    targets: [
        .target(name: "ProcessOut", dependencies: []),
        .testTarget(name: "ProcessOutTests", dependencies: ["ProcessOut"]),
    ]
)
