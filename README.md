# ProcessOut

Get started with our [ProcessOut documentation](https://docs.processout.com/) or browse the [SDK reference](https://processout.github.io/processout-ios/documentation/processout).

## Requirements

*iOS 12.0+*

## Modules

| Module                | Description                                                                  |
| --------------------- | ---------------------------------------------------------------------------- |
| ProcessOut            | Allows to interact with ProcessOut API and provides a UI to handle payments. |
| ProcessOutCheckout3DS | Integration with Checkout.com 3D Secure (3DS) mobile SDK.                    |

## Contributing

We welcome contributions of any kind including new features, bug fixes, and general improvements.

### Development requirements

- A recent version of macOS (tested with 13.3.1)
- A recent version of Xcode (tested with 14.3.1)
- [Homebrew](https://https://brew.sh/) package manager
- [Ruby](https://www.ruby-lang.org) (tested with 3.1.2) with [bundler](https://bundler.io) installed

### Installation

Before going further please make sure that you have installed all dependencies specified in [requirements](#development-requirements) section. Then in order to install remaining dependencies and prepare a project run `./Scripts/BootstrapProject.sh` script from repository's root directory. It will create `ProcessOut.xcodeproj` project that should be used for development.

> **Note**
> 
> If you plan to run tests ensure that `Tests/ProcessOutTests/Resources/Constants.yml` file with test project credentials exists before generating project. E.g.
>
> ```yml
> projectId: test-proj_K3Ur9LQzcKtm4zttWJ7oAKHgqdiwboAw
> projectPrivateKey: key_test_RE14RLcNikkP5ZXMn84BFYApwotD05Kc
> apiBaseUrl: https://api.processout.com
> checkoutBaseUrl: https://checkout.processout.com
> ```

### Running tests

To run tests locally use `./Scripts/Test.sh` script. It is also possible to run them directly in Xcode from the ProcessOut target in `ProcessOut.xcodeproj`.

## License

ProcessOut is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
