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
         sourceViewController?.dismiss(animated: true)
         completion(result)
      }
   )
   sourceViewController.present(viewController, animated: true)
}
```

When using `SFSafariViewController` your application should support deep links. When
application receives incoming URL you should allow ProcessOut SDK to handle it. For example
if you are using scene delegate it may look like following:

```swift
func scene(_ scene: UIScene, openURLContexts urlContexts: Set<UIOpenURLContext>) {
   guard let url = urlContexts.first?.url else {
      return
   }
   let isHandled = ProcessOut.shared.processDeepLink(url: url)
   print(isHandled)
}
```

We also provide ``POWebAuthenticationSession`` that can handle 3DS Redirects and does not depend on the UIKit framework.
This means that the controller can be used in places where a view controller cannot (for example, in SwiftUI
applications).

```swift
let session = POWebAuthenticationSession(redirect: redirect, returnUrl: Constants.returnUrl) { result in 
    // todo: handle completion
}
Task { await session.start() }
```
