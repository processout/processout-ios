# Getting Started with Native Alternative Payments

## Overview

Whenever you decide to initiate a payment, you should use ``PONativeAlternativePaymentMethodViewControllerBuilder`` to
create a view controller.

The most basic implementation may look like following:

```swift
let viewController = PONativeAlternativePaymentMethodViewControllerBuilder()
    .with(invoiceId: "invoice_id")
    .with(gatewayConfigurationId: "gateway_configuration_id")
    .with { result in
        // TODO: Handle result and hide controller
    }
    .build()
```

It's a caller's responsibility to present created controller in a preferred way. One could do it modally or by pushing
onto navigation stack or any other way.

## Customization

View controller could be further customized via builder, this includes both UI, and its behavior.

In order to tweak controller's styling, you should create an instance of ``PONativeAlternativePaymentMethodStyle`` structure
and pass it to ``PONativeAlternativePaymentMethodViewControllerBuilder/with(style:)`` method when creating controller.  

Let's say you want to change pay button's appearance:

```swift
let payButtonStyle = POButtonStyle(
    normal: .init(
        title: .init(color: .black, typography: .init(font: .systemFont(ofSize: 14), textStyle: .body)),
        border: .clear(radius: 8),
        shadow: .clear,
        backgroundColor: .green
    ),
    highlighted: .init(
        title: .init(color: .black, typography: .init(font: .systemFont(ofSize: 14), textStyle: .body)),
        border: .clear(radius: 8),
        shadow: .clear,
        backgroundColor: .yellow
    ),
    disabled: .init(
        title: .init(color: .gray, typography: .init(font: .systemFont(ofSize: 14), textStyle: .body)),
        border: .clear(radius: 0),
        shadow: .clear,
        backgroundColor: .darkGray
    ),
    activityIndicator: .system(.medium)
)
let style = PONativeAlternativePaymentMethodStyle(
    actions: .init(primary: payButtonStyle, axis: .vertical)
)
let viewController = builder.with(style: style).build()
```

Rather than changing styling you could change displayed data, for example to change screen's title and action button text
you could do:

```swift
let configuration = PONativeAlternativePaymentMethodConfiguration(
    title: "Pay here", primaryActionTitle: "Submit"
)
let viewController = builder.with(configuration: configuration).build()
```

You can also pass delegate that conforms to ``PONativeAlternativePaymentMethodDelegate`` to be notified of events and
alter run-time behaviors, use ``PONativeAlternativePaymentMethodViewControllerBuilder/with(delegate:)`` to do so.
