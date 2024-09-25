# Getting Started with 3DS

## Overview

Some SDK methods may trigger 3DS flow, those methods could be identified by presence of required parameter
`threeDSService` whose argument should conform to ``PO3DSService`` protocol.
``POInvoicesService/authorizeInvoice(request:threeDSService:completion:)`` is an example of such method.

### 3DS2

Most PSPs have their own certified SDKs for 3DS2 in mobile apps but they all have equivalent features. `PO3DSService`
allows to abstract the details of 3DS handling and supply functionality in a consistent way. 

We officially support our own implementation `POTest3DSService` (defined in `ProcessOutUI` package) that emulates
the normal 3DS authentication flow.

Also, there is an integration with [Checkout](https://checkout.com) 3DS2 SDK that is available in `ProcessOutCheckout3DS`
package.

### 3DS Redirect

In order to handle redirects your application should support deep links. When application receives incoming URL you
should notify ProcessOut SDK so it has a chance to handle it. 

For example if you are using scene delegate it may look like following:

```swift
func scene(_ scene: UIScene, openURLContexts urlContexts: Set<UIOpenURLContext>) {
    guard let url = urlContexts.first?.url else {
    return
}
let isHandled = ProcessOut.shared.processDeepLink(url: url)
print(isHandled)
}
```
