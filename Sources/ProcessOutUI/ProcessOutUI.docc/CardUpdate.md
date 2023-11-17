# Getting Started with Card Update

## Overview

On iOS there is a SwiftUI ``POCardUpdateView`` that can be used to handle CVC updates. Alternatively you can
use ``POCardUpdateViewController`` in UIKit environment.

In order to create an instance you need to pass at least card ID and completion.

```swift
let configuration = POCardUpdateConfiguration(cardId: "ID")
let view = POCardUpdateView(configuration: configuration) { result in
   // todo: handle result
}

// todo: embed view into hierarchy
```

### Configuration

By default, implementation displays only basic information such title, CVC input and submit/cancel buttons. It
is recommended that you additionally pass card information to view, doing so will allow showing user a card that
is being updated.

Setting scheme also allows implementation to properly format CVC so is highly encouraged.

```swift
let cardInfo = POCardUpdateInformation(
   maskedNumber: "4010 **** **** **21",
   scheme: "visa", // aleternatively you can set IIN
   preferredScheme: "carte bancaire" // if was previously set
)
let configuration = POCardUpdateConfiguration(cardId: "ID", cardInformation: cardInfo)
```

During lifecycle view also gives a chance to its delegate to resolve card information dynamically. It calls
``POCardUpdateDelegate/cardInformation(cardId:)-7wujo`` to retrieve needed info. Please note that the method
is asynchronous.

See ``POCardUpdateConfiguration`` reference for other available configurations.

### Styling

In order to tweak view’s styling, you should create an instance of ``POCardUpdateStyle`` structure and pass it
to view. The way you set style depends on whether you are using SwiftUI or UIKit bindings. For view controller
pass style instance via init, for SwiftUI view you can use ``SwiftUI/View/cardUpdateStyle(_:)`` modifier.

### Errors Recovery

By default, implementation allow user to recover from all errors (not including cancellation). If you wish to
change this behavior, you can implement delegate’s ``POCardUpdateDelegate/shouldContinueUpdate(after:)-3ax8v``
method. Where based on a given failure, you should decide if user should be allowed to continue or flow should
be ended.

For example following implementation allows to recover only from validation errors. All other error kinds result in
abort.

```swift
func shouldContinueUpdate(after failure: POFailure) -> Bool {
   if case .validation = failure.code {
      return true
   }
   return false
}
```

### Lifecycle Events

During lifecycle view emits multiple events that allow to understand user behavior, in order to observe them
implement delegate's ``POCardUpdateDelegate/cardUpdateDidEmitEvent(_:)-5mhya`` method.

### Localization

View can handle both LTR and RTL layout directions but not all languages are supported out of the box. You can add
missing localizations without modifying SDK. To do so add `ProcessOut.strings` and/or `ProcessOut.xcstrings` files
to your main bundle with following keys:

| Key                       | Description               |
|---------------------------|---------------------------|
| card-update.title         | Screen title              |
| card-update.cvc           | CVC placeholder           |
| card-update.submit-button | Submit button title       |
| card-update.cancel-button | Cancel button title       |
| card-update.error.cvc     | CVC error description     |
| card-update.error.generic | Generic error description |

To avoid mixed languages in UI please make sure that values for all keys are set.
