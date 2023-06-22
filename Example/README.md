# Example

Project demonstrates multiple flows that ProcessOut framework is capable of.

## Requirements

- A recent version of macOS (tested with 13.3.1)
- A recent version of Xcode (tested with 14.3.1)
- [Mint](https://github.com/yonaskolb/Mint) package manager

### Installation

1. Create `Example/Resources/Constants.yml` file with your project credentials. E.g.

```yml
projectId: test-proj_K3Ur9LQzcKtm4zttWJ7oAKHgqdiwboAw
projectPrivateKey: key_test_RE14RLcNikkP5ZXMn84BFYApwotD05Kc
customerId: cust_dCFEWBwqWrBFYAtkRIpILCynNqfhLQWX
apiBaseUrl: https://api.processout.com
checkoutBaseUrl: https://checkout.processout.com
```

2. Run `./Scripts/BootstrapProject.sh` script.
3. Open `Example.xcodeproj` project.
