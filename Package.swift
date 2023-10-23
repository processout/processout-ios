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
        .library(name: "ProcessOutCheckout3DS", targets: ["ProcessOutCheckout3DS"])
    ],
    dependencies: [
        // todo(andrii-vysotskyi): stop vendoring CKO 3DS SDK and dependencies when SPM support is ready.
        .package(url: "https://github.com/checkout/checkout-event-logger-ios-framework", exact: "1.2.4"),
    ],
    targets: [
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
                .product(
                    name: "CheckoutEventLoggerKit", package: "checkout-event-logger-ios-framework"
                ),
                .target(name: "JOSESwift"),
                .target(name: "Checkout3DS")
            ]
        ),
        .binaryTarget(
            name: "Checkout3DS", path: "Vendor/Checkout3DS.xcframework"
        ),
        .binaryTarget(
            name: "JOSESwift", path: "Vendor/JOSESwift.xcframework"
        ),
        .binaryTarget(name: "cmark", path: "Vendor/cmark.xcframework")
    ]
)
