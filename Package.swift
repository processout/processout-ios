// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "ProcessOut",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "ProcessOut", targets: ["ProcessOut"]),
        .library(name: "ProcessOutCoreUI", targets: ["ProcessOutCoreUI"]),
        .library(name: "ProcessOutUI", targets: ["ProcessOutUI"]),
        .library(name: "ProcessOutCheckout3DS", targets: ["ProcessOutCheckout3DS"]),
        .library(name: "ProcessOutNetcetera3DS", targets: ["ProcessOutNetcetera3DS"])
    ],
    dependencies: [
        .package(url: "https://github.com/checkout/checkout-3ds-sdk-ios", exact: "3.2.11"),
        .package(url: "https://github.com/swiftlang/swift-cmark", from: "0.7.1"),
        .package(url: "https://github.com/ios-3ds-sdk/SPM", exact: "2.5.32")
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
            name: "ProcessOutNetcetera3DS",
            dependencies: [
                .target(name: "ProcessOut"),
                .target(name: "NetceteraShim"),
                .product(name: "ThreeDS_SDK", package: "SPM")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .binaryTarget(
            name: "NetceteraShim", path: "./Vendor/NetceteraShim.xcframework"
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
                .target(name: "ProcessOut")
            ],
            resources: [
                .process("Resources")
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
