// swift-tools-version: 6.0

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableExperimentalFeature("IsolatedAny"),
    .enableUpcomingFeature("StrictConcurrency")
]

let package = Package(
    name: "ProcessOut",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "ProcessOut", targets: ["ProcessOut"]),
        .library(name: "ProcessOutCoreUI", targets: ["ProcessOutCoreUI"]),
        .library(name: "ProcessOutUI", targets: ["ProcessOutUI"]),
        .library(name: "ProcessOutCheckout3DS", targets: ["ProcessOutCheckout3DS"])
    ],
    dependencies: [
        .package(url: "https://github.com/checkout/checkout-3ds-sdk-ios", exact: "3.2.4"),
    ],
    targets: [
        .target(
            name: "ProcessOut",
            dependencies: [
                .target(name: "cmark")
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "ProcessOutCheckout3DS",
            dependencies: [
                .target(name: "ProcessOut"),
                .product(name: "Checkout3DSPackages", package: "checkout-3ds-sdk-ios")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "ProcessOutUI",
            dependencies: [
                .target(name: "ProcessOut"), .target(name: "ProcessOutCoreUI")
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "ProcessOutCoreUI",
            dependencies: [
                .target(name: "cmark")
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: swiftSettings
        ),
        .binaryTarget(name: "cmark", path: "Vendor/cmark.xcframework")
    ]
)
