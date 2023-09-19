// swift-tools-version: 5.9

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
            exclude: ["ProcessOut.docc", "swiftgen.yml"],
            resources: [
                .process("Resources")
            ]
        ),
        .binaryTarget(name: "cmark", path: "Vendor/cmark.xcframework")
    ]
)
