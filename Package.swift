// swift-tools-version: 5.10

import PackageDescription

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
        .package(url: "https://github.com/checkout/checkout-3ds-sdk-ios", exact: "3.2.5"),
        .package(url: "https://github.com/swiftlang/swift-cmark", from: "0.5.0")
    ],
    targets: [
        .target(
            name: "ProcessOut",
            dependencies: [
                .product(name: "cmark-gfm", package: "swift-cmark")
            ],
            resources: [
                .process("Resources")
            ]
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
            swiftSettings: [
                .enableUpcomingFeature("IsolatedDefaultValues")
            ]
        ),
        .target(
            name: "ProcessOutCoreUI",
            dependencies: [
                .product(name: "cmark-gfm", package: "swift-cmark")
            ],
            resources: [
                .process("Resources")
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
