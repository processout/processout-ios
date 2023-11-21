# Getting Started with 3DS

### 3DS2

``POTest3DSService`` emulates the normal 3DS authentication flow but does not actually make any calls to a real
Access Control Server (ACS). It is mainly useful during development in our sandbox testing environment.

### 3DS Redirect

``SafariServices/SFSafariViewController/init(redirect:returnUrl:safariConfiguration:completion:)`` allows you to create
a view controller that will automatically redirect user to expected url and collect result.

```swift
func handle(redirect: PO3DSRedirect, completion: @escaping (Result<String, POFailure>) -> Void) {
   let viewController = SFSafariViewController(
      redirect: redirect,
      returnUrl: Constants.returnUrl,
      completion: { [weak sourceViewController] result in
         sourceViewController.dismiss(animated: true)
         completion(result)
      }
   )
   sourceViewController.present(viewController, animated: true)
}
```

When using `SFSafariViewController` your application should support deep and/or universal links. When
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

We also provide ``PO3DSRedirectController`` that can handle 3DS Redirects and does not depend on the UIKit framework.
This means that the controller can be used in places where a view controller cannot (for example, in SwiftUI
applications).

```swift
let controller = PO3DSRedirectController(redirect: redirect, returnUrl: Constants.returnUrl)
controller.completion = { [weak controller] result in
   controller?.dismiss { completion(result) }
}
controller.present()
```
