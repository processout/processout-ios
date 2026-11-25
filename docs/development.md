# Development setup

This document describes how to set up, build and test the SDK on a Mac.

## Requirements

| Tool                  | Version       | Purpose                                                                              |
| --------------------- | ------------- | ------------------------------------------------------------------------------------ |
| Xcode                 | 26.2 or later | Builds the SDK. CI uses Xcode 26.2.                                                  |
| iOS simulator runtime | iOS 26        | Runs the tests. The test scripts select the latest iOS 26 iPhone simulator.          |
| [Homebrew][homebrew]  | Latest        | Installs the command-line tools that the project needs.                              |
| [xcpretty][xcpretty]  | Latest        | Optional. Formats the output of `Run.sh`. To install it, run `gem install xcpretty`. |

### Homebrew

Homebrew is required. The bootstrap script installs the tools in `Brewfile` with `brew bundle`, and the Xcode build
phases run these tools.

| Tool        | Use                                                                                      |
| ----------- | ---------------------------------------------------------------------------------------- |
| `xcodegen`  | Generates `ProcessOut.xcodeproj` from `project.yml`.                                     |
| `swiftlint` | Lints the sources in strict mode in each build. A lint violation fails the build.        |
| `sourcery`  | Generates code in `Sources/ProcessOut/Sources/Generated/` in each build of `ProcessOut`. |

The build phases add `/opt/homebrew/bin`, the default Homebrew location on Apple silicon Macs, to `PATH`. If you
install Homebrew in a different location, the build phases may not find the tools.

## Setup

1. Install the [requirements](#requirements).
2. From the repository root, run `./Scripts/BootstrapProject.sh`. The script installs the tools in `Brewfile` and
   generates `ProcessOut.xcodeproj`.
3. Open `ProcessOut.xcodeproj`.

`ProcessOut.xcodeproj` is generated and not committed. If you change `project.yml` or switch to a branch that changes
it, run `./Scripts/BootstrapProject.sh` again.

## Tests

### Test credentials

Integration tests in `Tests/*/Sources/Integration/` call the ProcessOut API with a test project. Unit tests in
`Tests/*/Sources/Unit/` do not need credentials.

To run integration tests, set the constants in these files to the credentials of your test project:

- `Tests/ProcessOutTests/Sources/Core/Constants.swift`
- `Tests/ProcessOutUITests/Sources/Core/Constants.swift`

```swift
enum Constants {

    /// Project ID.
    static let projectId = "test-proj_your_project_id"

    /// Project private key.
    static let projectPrivateKey = "key_test_your_private_key"

    /// Customer ID.
    static let customerId = "cust_your_customer_id"
}
```

Do not commit the credentials. CI writes the constants from the `TEST_PROJECT_CONSTANTS` repository secret.

### Running tests

To run every test suite, run `./Scripts/Tests/Run.sh`. The script tests `ProcessOut`, `ProcessOutUI`,
`ProcessOutCheckout3DS` and `ProcessOutNetcetera3DS`. `ProcessOutCoreUI` has no tests of its own. The `ProcessOutUI`
tests cover it.

To test one module from the command line, run the following command with the scheme of that module:

```bash
xcodebuild test -project ProcessOut.xcodeproj -scheme ProcessOut -destination "$(./Scripts/Tests/Destination.swift)"
```

To test one module in Xcode, select the scheme of that module and choose **Product > Test**.

Without credentials, the integration tests of `ProcessOut` and `ProcessOutUI` fail. `Run.sh` stops at the first module
that fails, so it does not test the other modules. In that case, test each module separately with the command above.
Then check the unit test results of each module.

## Linting

To lint without a build, run `./Scripts/Lint.sh`.

[homebrew]: https://brew.sh
[xcpretty]: https://github.com/xcpretty/xcpretty
