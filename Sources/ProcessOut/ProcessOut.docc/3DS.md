# Getting Started with 3DS

## Overview

Some SDK methods may trigger 3DS flow, those methods could be identified by presence of required parameter
`threeDSService` whose argument should conform to ``PO3DSService`` protocol.
``POInvoicesService/authorizeInvoice(request:threeDSService:completion:)`` is an example of such method.

### 3DS2

Most PSPs have their own certified SDKs for 3DS2 in mobile apps but they all have equivalent features. `PO3DSService`
allows to abstract the details of 3DS handling and supply functionality in a consistent way. 

We officially support our own implementation ``POTest3DSService`` of `PO3DSService` that emulates the normal 3DS
authentication flow but does not actually make any calls to a real Access Control Server (ACS). It is mainly useful
during development in our sandbox testing environment. Also, there is an integration with [Checkout](https://checkout.com)
3DS2 SDK that is available in separate `ProcessOutCheckout3DS` package.

### 3DS Redirect

Method ``PO3DSService/handle(redirect:completion:)`` is a part of 3DS service that is responsible for handling web
based redirects. ``PO3DSRedirectViewControllerBuilder`` allows you to create a view controller that will automatically
redirect user to expected url and collect result. 

```swift
func handle(redirect: PO3DSRedirect, completion: @escaping (Result<String, POFailure>) -> Void) {
    let viewController = PO3DSRedirectViewControllerBuilder 
        .with(redirect: redirect)
        .with(returnUrl: Constants.returnUrl)
        .with(completion: { result in
            sourceViewController.dismiss(animated: true)
            completion(result) 
        })
        .build()
    sourceViewController.present(viewController, animated: true)
}
```

When using `PO3DSRedirectViewControllerBuilder` your application should support deep and/or universal links. When
application receives incoming URL you should allow ProcessOut SDK to handle it. For example if you are using scene
delegate and universal links it may look like following:

```swift
func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
    guard let url = userActivity.webpageURL else {
        return
    }
    let isHandled = ProcessOut.shared.processDeepLink(url: url)
    print(isHandled)
}
```
