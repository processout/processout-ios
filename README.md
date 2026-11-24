# ProcessOut

Get started with the [ProcessOut documentation](https://docs.processout.com/) or browse the SDK reference:

- [ProcessOut](https://swiftpackageindex.com/processout/processout-ios/documentation/processout)
- [ProcessOutCheckout3DS](https://swiftpackageindex.com/processout/processout-ios/documentation/processoutcheckout3ds)
- [ProcessOutCoreUI](https://swiftpackageindex.com/processout/processout-ios/documentation/processoutcoreui)
- [ProcessOutNetcetera3DS](https://swiftpackageindex.com/processout/processout-ios/documentation/processoutnetcetera3ds)
- [ProcessOutUI](https://swiftpackageindex.com/processout/processout-ios/documentation/processoutui)

## Requirements

*iOS 15.0+*

## Modules

| Module                   | Description                                       |
| ------------------------ | ------------------------------------------------- |
| `ProcessOut`             | Access to the ProcessOut API.                     |
| `ProcessOutCheckout3DS`  | Integration with the Checkout.com 3DS mobile SDK. |
| `ProcessOutCoreUI`       | Shared styling primitives for `ProcessOutUI`.     |
| `ProcessOutNetcetera3DS` | Integration with the Netcetera 3DS mobile SDK.    |
| `ProcessOutUI`           | Prebuilt SwiftUI UI for payments.                 |

> [!NOTE]
>
> The UIKit UI in `ProcessOut` is deprecated, and version `5.0.0` will remove it. Use `ProcessOutUI` instead.

## Contributing

We welcome contributions of any kind: new features, bug fixes and improvements. Before you contribute, read the
[project documentation](docs/README.md).

### Development requirements

- Xcode 26.2 or later
- [Homebrew](https://brew.sh/) package manager

### Installation

1. Install the [development requirements](#development-requirements).
2. From the repository root, run `./Scripts/BootstrapProject.sh`. The script installs the Homebrew dependencies and
   generates `ProcessOut.xcodeproj`.
3. Open `ProcessOut.xcodeproj` for development.

> [!NOTE]
> 
> Before you run tests, set the constants in `Tests/ProcessOutTests/Sources/Core/Constants.swift` and
> `Tests/ProcessOutUITests/Sources/Core/Constants.swift` to test project credentials:
>
> ```swift
> enum Constants {
>
>    /// Project ID.
>    static let projectId = "test-proj_K3Ur9LQzcKtm4zttWJ7oAKHgqdiwboAw"
>
>    /// Project's private key.
>    static let projectPrivateKey = "key_test_RE14RLcNikkP5ZXMn84BFYApwotD05Kc"
>
>    /// Customer ID.
>    static let customerId = "cust_dCFEWBwqWrBFYAtkRIpILCynNqfhLQWX"
> }
> ```

### Running tests

Run `./Scripts/Tests/Run.sh`. You can also run the tests in Xcode from the `ProcessOut` target in
`ProcessOut.xcodeproj`.

## License

ProcessOut is available under the MIT license. See [LICENSE](LICENSE).
