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
        .library(name: "ProcessOutCheckout3DS", type: .dynamic, targets: ["ProcessOutCheckout3DS"])
    ],
    dependencies: [
        // todo(andrii-vysotskyi): replace branch with version where feature is released.
        .package(url: "https://github.com/checkout/checkout-3ds-sdk-ios", branch: "feature/PIMOB-2035_support_spm")
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
        .target(
            name: "ProcessOutCheckout3DS",
            dependencies: [
                .target(name: "ProcessOut"),
                .product(name: "Checkout3DSPackages", package: "checkout-3ds-sdk-ios")
            ],
            exclude: ["ProcessOutCheckout3DS.docc"]
        ),
        .binaryTarget(name: "cmark", path: "Vendor/cmark.xcframework")
    ]
)
