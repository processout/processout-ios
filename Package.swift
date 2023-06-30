// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "ProcessOut",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(name: "ProcessOut", targets: ["ProcessOut"]),
    ],
    targets: [
        .target(
            name: "ProcessOut",
            dependencies: [
                .target(name: "cmark")
            ],
            // Having DocC in sources may cause build failures so excluded until issue is resolved by Apple. See
            // https://forums.swift.org/t/xcode-and-swift-package-manager/44704 for details.
            exclude: ["ProcessOut.docc"],
            resources: [
                .process("Resources")
            ]
        ),
        .binaryTarget(name: "cmark", path: "Vendor/cmark.xcframework")
    ]
)
