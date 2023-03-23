# Getting Started with 3DS

## Overview

Some SDK methods may trigger 3DS flow, those methods could be identified by presence of required parameter
`threeDSService` whose argument should conform to ``PO3DSServiceType`` protocol.
``POInvoicesServiceType/authorizeInvoice(request:threeDSService:completion:)`` is an example of such method.

### 3DS2

Most PSPs have their own certified SDKs for 3DS2 in mobile apps but they all have equivalent features. `PO3DSServiceType`
allows to abstract the details of 3DS handling and supply functionality in a consistent way. 

We officially support our own implementation of `PO3DSServiceType` to use with [Checkout](https://checkout.com) service.
Check `ProcessOutCheckout` target for details. 

There is also `CardPaymentTest3DSService` defined in Example application that emulates the normal 3DS authentication
flow but does not actually make any calls to a real Access Control Server (ACS). It is mainly useful during development
in our sandbox testing environment.

### 3DS Redirect

Method ``PO3DSServiceType/handle(redirect:completion:)`` is a part of 3DS service that is responsible for handling web
based redirects.

``PO3DSRedirectViewControllerBuilder`` allows you to create a view controller that will automatically
redirect user to expected url and collect result. 

Please note that some redirects can be handled silently to user, in order to understand whether it is possible inspect
``PO3DSRedirect/isHeadlessModeAllowed``. If value of this property is `true` redirect can be handled without showing
any additional UI to user. One way to implement such presentation could be like following:

```swift
func handle(redirect: PO3DSRedirect, completion: @escaping (Result<String, POFailure>) -> Void) {
    if redirect.isHeadlessModeAllowed {
        var viewController: UIViewController!
        viewController = PO3DSRedirectViewControllerBuilder
            .with(redirect: redirect)
            .with(completion: { result in
                // TODO: remove view controller and its view from parent
                completion(result) 
            })
            .build()
        sourceViewController.addChild(viewController)
        sourceViewController.view.addSubview(viewController.view)
        viewController.view.frame = .zero
        viewController.didMove(toParent: sourceViewController)
    } else {
        let viewController = PO3DSRedirectViewControllerBuilder 
            .with(redirect: redirect)
            .with(completion: { result in
                sourceViewController.dismiss(animated: true)
                completion(result) 
            })
            .build()
        sourceViewController.present(viewController, animated: true)
    }
}
```
