# Getting Started with Native Alternative Payments

## Overview

When you need to authorize an invoice using native alternative payment create an instance of
``PONativeAlternativePaymentView`` and embed it into view hierarchy.

```swift
let configuration = PONativeAlternativePaymentConfiguration(
   invoiceId: "invoice_id",
   gatewayConfigurationId: "gateway_configuration_id"
)
let view = PONativeAlternativePaymentView(configuration: configuration) { result in
   // TODO: Handle result and hide view
}
```

Alternatively in UIKit environment you can use ``PONativeAlternativePaymentViewController``. It is also created via
`init` where the only difference is additional optional `style` argument (explained later).

Please note that it's a caller responsibility to present created view/controller in a preferred way. One could do it
modally or by pushing onto navigation stack or in any other way.

### Configuration

Rather than changing styling you could change displayed data, for example to change screen's title and action button
text you could do:

```swift
PONativeAlternativePaymentConfiguration(
..., title: "Pay here", primaryActionTitle: "Submit"
)
let view = PONativeAlternativePaymentView(configuration: configuration, ...)
```

You can also create view with delegate that conforms to ``PONativeAlternativePaymentDelegate`` to be notified of events
and alter run-time behaviors.

### Styling

In order to tweak view’s styling, you should create an instance of ``PONativeAlternativePaymentStyle`` structure
and pass it to view. The way you set style depends on whether you are using SwiftUI or UIKit bindings. For view
controller pass style instance via init, for SwiftUI view you should use ``SwiftUI/View/nativeAlternativePaymentStyle(_:)``
modifier.

Let's say you want to change pay button's appearance:

```swift
let payButtonStyle = POButtonStyle(
   normal: .init(
      title: .init(color: .black, typography: .init(font: .system(size: 14))),
      border: .clear(),
      shadow: .clear,
      backgroundColor: .green
   ),
   highlighted: .init(
      title: .init(color: .black, typography: .init(font: .system(size: 14))),
      border: .clear(),
      shadow: .clear,
      backgroundColor: .yellow
   ),
   disabled: .init(
      title: .init(color: .gray, typography: .init(font: .system(size: 14))),
      border: .clear(),
      shadow: .clear,
      backgroundColor: .darkGray
   ),
   progressStyle: .system(.medium)
)
let style = PONativeAlternativePaymentStyle(
   actionsContainer: .init(primary: payButtonStyle, secondary: .secondary, axis: .horizontal)
)
```

Please note that `POButtonStyle` is an implementation of `SwiftUI.ButtonStyle` that exists for convenience. If you need
to further customize the appearance you should define your own type that conforms to SwiftUI.ButtonStyle protocol and
pass its instance instead. The same applies to `PORadioButtonStyle` and progress view style.

For additional details on specific components styling, see dedicated
[documentation.](https://swiftpackageindex.com/processout/processout-ios/documentation/processoutcoreui)
