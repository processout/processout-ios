# Example

Project demonstrates multiple flows that ProcessOut framework is capable of.

## Requirements

- A recent version of Xcode (tested with 15.4)
- [Homebrew](https://brew.sh) package manager

### Installation

1. Run `./Scripts/BootstrapProject.sh` script.

2. Open `Example.xcodeproj` project.

3. Set constants defined in `Example/Sources/Application/Constants.swift` file to your project credentials. E.g.:

```swift
enum Constants {

    /// Project ID.
    static var projectId = "test-proj_K3Ur9LQzcKtm4zttWJ7oAKHgqdiwboAw"

    /// Project private key.
    static var projectPrivateKey = "key_test_RE14RLcNikkP5ZXMn84BFYApwotD05Kc"

    /// Customer ID.
    static var customerId = "cust_dCFEWBwqWrBFYAtkRIpILCynNqfhLQWX"

    ...
}
```
