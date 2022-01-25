# ProcessOut

[![Version](https://img.shields.io/cocoapods/v/ProcessOut.svg?style=flat)](http://cocoapods.org/pods/ProcessOut)
[![License](https://img.shields.io/cocoapods/l/ProcessOut.svg?style=flat)](http://cocoapods.org/pods/ProcessOut)
[![Platform](https://img.shields.io/cocoapods/p/ProcessOut.svg?style=flat)](http://cocoapods.org/pods/ProcessOut)

## Requirements

*iOS 8.0+*

## Installation

ProcessOut is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ProcessOut'
```

## Usage
### Setup
You must specify your `ProjectId` in your `AppDelegate` file:
```swift
ProcessOut.Setup(projectId: "your_project_id")
```

### Card token

To retrieve a card token simply instantiate a card object using:
- card number - String
- expiration month - Int
- expiration year - Int (both `2019` and `19` formats are accepted)
- cvc - String
- card holder name - String

```swift
ProcessOut.Tokenize(card: card, metadata: [:], completion: {(token, error) -> Void in
    if error != nil {
        switch error! {
        case .BadRequest(let message, let errorCode):
            // developers, message can help you
            print(message, errorCode)
        case .InternalError:
            print("An internal error occured")
        case .MissingProjectId:
            print("Check your app delegate file")
        case .NetworkError:
            print("Request could not go through")
        }
    } else {
        // send token to your backend to charge the customer
        print(token!)
    }
})
```
### Update a card CVC

```swift
ProcessOut.UpdateCvc(cardId: "a_card_token", newCvc: "123", completion: { (error) in
    if error != nil {
        // an error occured
        print(error!)
    } else {
        // card CVC updated
    }
})
```

## Contributing

### Requirements

- A recent version of macOS (tested with version 12.1)
- A recent version of Xcode (tested with version 13.2)
- [Cocoapods](https://cocoapods.org/)

### Running the example project

1. In the `Example/` directory, install the dependencies using [Cocoapods](https://cocoapods.org/)

```Shell
$ pod install
```

2. Using Xcode, open `ProcessOut.xcworkspace`

3. Build and run the project by choosing Product > Run in the Xcode menu bar

## Author

Jeremy Lejoux, jeremy@processout.com

## License

ProcessOut is available under the MIT license. See the LICENSE file for more info.
