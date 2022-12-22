// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "ProcessOut",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "ProcessOut", targets: ["ProcessOut"]),
    ],
    targets: [
        .target(name: "ProcessOut", dependencies: [], path: "ProcessOut/Classes"),
    ]
)
