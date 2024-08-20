# ProcessOut

Get started with our ProcessOut [documentation](https://docs.processout.com/) or browse the SDK reference:

- [ProcessOut](https://swiftpackageindex.com/processout/processout-ios/documentation/processout)
- [ProcessOutCheckout3DS](https://swiftpackageindex.com/processout/processout-ios/documentation/processoutcheckout3ds)
- [ProcessOutUI](https://swiftpackageindex.com/processout/processout-ios/documentation/processoutui)

## Requirements

*iOS 13.0+*

## Modules

| Module                | Description                                                                  |
| --------------------- | ---------------------------------------------------------------------------- |
| ProcessOut            | Allows to interact with ProcessOut API and provides a UI to handle payments. |
| ProcessOutCheckout3DS | Integration with Checkout.com 3D Secure (3DS) mobile SDK.                    |
| ProcessOutUI          | ProcessOut prebuilt UI to handle payments.                                   |

> [!NOTE]
>
> We are currently in the process of migrating UI from ProcessOut to ProcessOutUI module. The new module
> is based on SwiftUI, so styling is not compatible with ProcessOut (that is based on UIKit). Also
> beware that UI in ProcessOut will be removed in `5.0.0`.

## Contributing

We welcome contributions of any kind including new features, bug fixes, and general improvements.

### Development requirements

- A recent version of Xcode (tested with 15.4)
- [Homebrew](https://brew.sh/) package manager

### Installation

Before going further please make sure that you have installed all dependencies specified in [requirements](#development-requirements) section. Then in order to install remaining dependencies and prepare a project run `./Scripts/BootstrapProject.sh` script from repository's root directory. It will create `ProcessOut.xcodeproj` project that should be used for development.

> [!NOTE]
> 
> If you plan to run tests ensure that constants defined in `Tests/ProcessOutTests/Sources/Core/Constants.swift` and `Tests/ProcessOutUITests/Sources/Core/Constants.swift` are set to test project credentials. E.g.:
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

To run tests locally use `./Scripts/Test.sh` script. It is also possible to run them directly in Xcode from the ProcessOut target in `ProcessOut.xcodeproj`.

## License

ProcessOut is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
