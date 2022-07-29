// swift-tools-version:5.5
import PackageDescription

let package = Package(
  name: "ProcessOut",
  defaultLocalization: "en",
  platforms: [.iOS(.v10)],
  products: [.library(name: "ProcessOut", targets: ["ProcessOut"])],
  dependencies: [],
  targets: [
    .target(name: "ProcessOut", dependencies: [], path: "ProcessOut")
  ]
)
