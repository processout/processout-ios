// swift-tools-version: 5.9

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
//        .package(url: "https://github.com/checkout/checkout-3ds-sdk-ios", exact: "3.2.1"),
        .package(url: "https://github.com/checkout/checkout-event-logger-ios-framework.git", from: "1.2.4")
    ],
    targets: [
        .binaryTarget(
            name: "Checkout3DS",
            path: "Vendor/Checkout3DS.xcframework"
        ),
        .binaryTarget(
            name: "JOSESwift",
            path: "Vendor/JOSESwift.xcframework"
        ),
        .target(
            name: "ProcessOut",
            dependencies: [
                .target(name: "cmark")
            ],
            exclude: ["swiftgen.yml"],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "ProcessOutCheckout3DS",
            dependencies: [
                .target(name: "ProcessOut"),
                .target(name: "Checkout3DS"),
                .target(name: "JOSESwift"),
                .product(name: "CheckoutEventLoggerKit", package: "checkout-event-logger-ios-framework")
            ]
        ),
        .target(
            name: "ProcessOutUI",
            dependencies: [
                .target(name: "ProcessOut"), .target(name: "ProcessOutCoreUI")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "ProcessOutCoreUI",
            dependencies: [
                .target(name: "cmark")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .binaryTarget(name: "cmark", path: "Vendor/cmark.xcframework")
    ]
)
