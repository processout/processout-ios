# Getting Started with Dynamic Checkout 

## iOS

### Integrating the dynamic checkout UI

First, you should obtain and set up the ProcessOut [iOS SDK](https://github.com/processout/processout-ios) in your
project by following the [instructions](doc:setting-up-your-environment#ios-app-client) for iOS.

Depending on your setup, you need to use either a view or a view controller to present the UI for the dynamic checkout.

- For **SwiftUI** users, use the [PODynamicCheckoutView](https://swiftpackageindex.com/processout/processout-ios/documentation/processoutui/podynamiccheckoutview) view.
- For **UIKit** users, use the [PODynamicCheckoutViewController](https://swiftpackageindex.com/processout/processout-ios/documentation/processoutui/podynamiccheckoutviewcontroller) controller.

The creation process for both is similar, with the key difference being that for the UIKit version, you must pass
the style during initialization, as it cannot be set later.

Other parameters that should be passed when creating the view or view controller include the configuration and
delegate objects (discussed later).

After the payment is completed, the view calls a completion handler that you passed during its creation. This handler
receives a result object that indicates either a success or a failure.

```swift
import ProcessOutUI

let configuration = PODynamicCheckoutConfiguration(
   invoiceId: "iv_xyz"
)

let view = PODynamicCheckoutView(
   configuration: configuration,
   delegate: delegate
   completion: { result in
      // TODO: handle payment result
   }
)
```

This allows you to appropriately respond to the outcome of the payment process, ensuring a seamless user experience.

### Configuration

The view accepts a configuration object `PODynamicCheckoutConfiguration` that allows you to customize the displayed
information and the behavior of the checkout screen.

The only mandatory parameter is the **Invoice ID** you wish to authorize. Other optional parameters include, but
are not limited to:

- Card payment [configuration](#card-payment-configuration).
- Alternative payments [configuration](#alternative-payment-configuration).
- Modifying the visual and behavioral properties of the cancel button.
- Automatic payment method pre-selection.
- ApplePay button type.

*Example usage:*

```swift
let configuration = PODynamicCheckoutConfiguration(
   invoiceId: "iv_xzy",
   alternativePayment: PODynamicCheckoutAlternativePaymentConfiguration(
      returnUrl: URL(string: "processout://return"
   ),
   allowsSkippingPaymentList: false,
   ...
)

let view = PODynamicCheckoutView(configuration: configuration, ...)
```

#### Card payment configuration

Card payment settings are primarily set via the ProcessOut dashboard when creating a dynamic checkout configuration.
Additional settings within the SDK include:

- `defaultAddress`: Set this if you know the customer's billing address in advance.

- `attachDefaultsToPaymentMethod`: Property can be set to `true` if you want the implementation to fill in any fields
the user didn't enter with defaults. This is especially useful in combination with the `never` collection mode
(configured in dashboard) to set an address during card payment without allowing the user to change it.

*Example usage:*

```swift
let billingAddressConfiguration = PODynamicCheckoutCardConfiguration.BillingAddress(
   defaultAddress: .init(zip: "M44 5YN", countryCode: "GB"),
   attachDefaultsToPaymentMethod: false
)
let cardConfiguration = PODynamicCheckoutCardConfiguration(
   billingAddress: billingAddressConfiguration,
   metadata: [:]
)
let configuration = PODynamicCheckoutConfiguration(card: cardConfiguration, ...)
```

#### Alternative payment configuration

To support web-based alternative payment methods (APMs), ensure the returnUrl is set to a scheme-based deep link
supported by your application. Additionally, notify the ProcessOut SDK when users return to the app via a deep link.

For instance, using a scene delegate:

```swift
func scene(_ scene: UIScene, openURLContexts urlContexts: Set<UIOpenURLContext>) {
   guard let url = urlContexts.first?.url else {
      return  
   }
   let isHandled = ProcessOut.shared.processDeepLink(url: url)
}
```

Other options for native APMs include:

- Limiting the number of options displayed inline for single-choice parameters.
- Changing the maximum duration the implementation will wait for payment capture.
- Modifying the visual and behavioral properties of the cancel button.

For more detailed information, refer to the [SDK reference](https://swiftpackageindex.com/processout/processout-ios/documentation/processoutui/podynamiccheckoutconfiguration).

### Delegate

When creating a `PODynamicCheckoutView`, the delegate is a mandatory parameter that facilitates interaction and
decision-making throughout the checkout process. Below are the general responsibilities and specific tasks related to
different payment methods that the delegate handles:

#### General

- **Events:** Monitor events such as payment method selection and other interactions within the checkout flow.

- **Failure Recovery:** Decide whether the user should continue the checkout flow after encountering specific failures,
passed as an argument.

#### Card Payments

- **Card Tokenization Events:** Receive notifications about events related to card tokenization.

- **Preferred Card Network Selection:** When both scheme and co-scheme are available, determine which one to prefer.

- **Invoice Authorization:** When authorizing an invoice the SDK prepares a `POInvoiceAuthorizationRequest`. The delegate
implementation is given the opportunity to view and modify this request before it is processed. Additionally, your code
must provide a `PO3DSService` instance to handle 3DS authentication during the authorization process. 

#### Alternative Payments

- **Native Alternative Payment Events**

- **Default Parameter Values:** Provide default values for parameters that the user is expected to fill in during the
checkout process.

#### ApplePay

- **Payment Authorization:** When authorizing a payment using Apple Pay, your delegate is provided with the opportunity
to view and modify the `PKPaymentRequest` that will be used for the authorization process. It is crucial to set the
`paymentSummaryItems` in this request to ensure that the payment details are accurately displayed to the user.

For additional detailed information about the [PODynamicCheckoutDelegate](https://swiftpackageindex.com/processout/processout-ios/documentation/processoutui/podynamichceckoutdelegate)
and its methods, you can refer to the delegate reference documentation.

### Style

To further customize the UI of the dynamic checkout on iOS, you can create a custom style and inject it into the view
hierarchy using different methods depending on whether you are using SwiftUI or UIKit.

**Using SwiftUI**

In SwiftUI, you can customize the style by using the [dynamicCheckoutStyle](https://swiftpackageindex.com/processout/processout-ios/documentation/processoutui/swiftui/view/dynamiccheckoutstyle(_:))
method.

```swift
let style = PODynamicCheckoutStyle(backgroundColor: .gray, ...)

let view = PODynamicCheckoutView(
   configuration: configuration,
   delegate: delegate,
   completion: completion
).dynamicCheckoutStyle(customStyle)
```

**Using UIKit**

If you are using UIKit and `PODynamicCheckoutViewController`, you can pass the custom style directly during initialization.

```swift
let style = PODynamicCheckoutStyle(backgroundColor: .gray, ...)

let viewController = PODynamicCheckoutViewController(
   style: style,
   configuration: configuration,
   delegate: delegate,
   completion: completion
)
```

Customizing the UI allows you to match the checkout experience with your app's design guidelines and user
expectations effectively.

### API bindings

For a highly customizable approach, you can leverage our API bindings directly to retrieve and display payment
methods suitable for checkout.

Below is a code sample demonstrating how to fetch details, including dynamic checkout payment methods, for an existing
invoice.

```swift
import ProcessOut

// Create a request to get invoice details.
let request = POInvoiceRequest(id: "iv_xzy")

// Execute request
do {
   let invoice = try await ProcessOut.shared.invoices.invoice(request: request)
   // TODO: Inspect `invoice.paymentMethods` for available methods.
} catch {
   // TODO: Inspect `failure.code` for the detailed error reason.
}
```

This approach gives you flexibility in how you integrate and display payment methods based on the specific
requirements of your checkout process, enhancing user experience and customization capabilities.

To access a comprehensive list of all possible payment methods supported by ProcessOut for dynamic checkout, you
can refer to the [PODynamicCheckoutPaymentMethod](https://swiftpackageindex.com/processout/processout-ios/documentation/processout/podynamiccheckoutpaymentmethod)
enumeration.
