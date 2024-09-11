# Getting Started with 3DS

## Overview

Some SDK methods may trigger 3DS flow, those methods could be identified by presence of required parameter
`threeDSService` whose argument should conform to ``PO3DSService`` protocol.
``POInvoicesService/authorizeInvoice(request:threeDSService:)`` is an example of such method.

### 3DS2

Most PSPs have their own certified SDKs for 3DS2 in mobile apps but they all have equivalent features. `PO3DSService`
allows to abstract the details of 3DS handling and supply functionality in a consistent way. 

We officially support our own implementation `POTest3DSService` (defined in `ProcessOutUI` package) that emulates
the normal 3DS authentication flow.

Also, there is an integration with [Checkout](https://checkout.com) 3DS2 SDK that is available
in [`ProcessOutCheckout3DS`](https://swiftpackageindex.com/processout/processout-ios/documentation/processoutcheckout3ds)
package.

For additional details on 3DS UI see dedicated [documentation.](https://swiftpackageindex.com/processout/processout-ios/documentation/processoutui/3ds)
