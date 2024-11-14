# Example

Project demonstrates multiple flows that ProcessOut framework is capable of.

## Requirements

- A recent version of Xcode (tested with 16.0)
- [Homebrew](https://brew.sh) package manager

### Installation

1. Run `./Scripts/BootstrapProject.sh` script.

2. Open `Example.xcodeproj` project.

3. Set constants defined in `Example/Sources/Application/Constants.swift` file to your project credentials. E.g.:

```swift
@MainActor
enum Constants {

    /// Project configuration.
    @UserDefaultsStorage("Constants.projectConfiguration")
    static var projectConfiguration = ProcessOutConfiguration(
        projectId: "test-proj_K3Ur9LQzcKtm4zttWJ7oAKHgqdiwboAw"
    )

    /// Customer ID.
    @UserDefaultsStorage("Constants.customerId")
    static var customerId = "cust_dCFEWBwqWrBFYAtkRIpILCynNqfhLQWX"

    ...
}
```
