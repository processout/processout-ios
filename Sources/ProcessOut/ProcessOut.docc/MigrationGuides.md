# Migration Guides

## Migrating from versions < 5.0.0

- ``ProcessOutConfiguration`` is no longer created using the `func production(...)` static method. Instead, a regular
`init` should be used. See the example below:

  * Also it is no longer possible to pass the version directly when creating a `ProcessOutConfiguration`. Instead, set the
application object with the version.

```swift
let configuration = ProcessOutConfiguration(
   projectId: "test-proj_XZY",
   application: .init(name: "Example", version: "1.0.0"),
   isDebug: true,
   isTelemetryEnabled: true
)
```

- The ``ProcessOut/ProcessOut/shared`` instance must be [configured](``ProcessOut/ProcessOut/configure(configuration:force:)``)
exclusively on the main actor's thread. However, once configured, it is safe to use in multithreaded environment.

- It is no longer necessary to notify the framework of inbound deep links using
the `ProcessOut.shared.processDeepLink(url: url)` method. This method can be safely removed, as deep link processing
for both 3DS and alternative payments is now handled internally by the framework.

### Cards and Customer Tokens

- The card properties `scheme`, `coScheme`, `preferredScheme`, and `cvcCheck`, previously represented as strings,
are now represented by typed values: ``POCardScheme`` and ``POCardCvcCheck``. If you need to access the raw string
representation, use the `rawValue` property. This affects:

  * ``POCardTokenizationRequest``
  * ``POCardUpdateRequest``
  * ``POCard``
  * ``POCardIssuerInformation``
  * ``POAssignCustomerTokenRequest``
  * ``POInvoiceAuthorizationRequest``
  * `POCardTokenizationDelegate`
  * `POCardUpdateInformation`

### 3D Secure

- ``PO3DSService`` has been migrated to structured concurrency. To adapt your existing implementation, you could wrap it
using `withCheckedThrowingContinuation`. See the example below:

```swift
func authenticationRequestParameters(
   configuration: PO3DS2Configuration
) async throws -> PO3DS2AuthenticationRequestParameters {
   try await withCheckedThrowingContinuation { completion in
      <existing code>
   }
}
```

Additionally:

- The method `func authenticationRequest(configuration:completion:)` has been renamed to
``PO3DSService/authenticationRequestParameters(configuration:)``.

- The method `func handle(challenge:completion:)` has been renamed to ``PO3DSService/performChallenge(with:)``. In the
previous implementation, you were required to return a boolean value indicating whether the challenge was performed
successfully. In the new implementation, you should return a ``PO3DS2ChallengeResult``, which can be created using either
a string value or a boolean, depending on your 3DS provider.

- `POTest3DSService` is no longer part of the `ProcessOut` module. It can now be found in the `ProcessOutUI` module.

- The `PO3DS2Configuration`'s ``PO3DS2Configuration/scheme`` is no longer represented by `PO3DS2ConfigurationCardScheme`. It is now
represented by ``POCardScheme``, consistent with other card-related entities.

- Requests that previously exposed the `enableThreeDS2` property no longer do so. This property is now considered an
implementation detail and should always be set to `true` for API requests made from mobile. This affects:

  * ``POAssignCustomerTokenRequest``
  * ``POInvoiceAuthorizationRequest``

### Alternative Payments

- `POAlternativePaymentMethodsService` has been renamed to ``POAlternativePaymentsService`` and can now be accessed
using the ``ProcessOut/ProcessOut/alternativePayments`` method.

  * `POAlternativePaymentTokenizationRequest` has been removed. Instead, use the dedicated `POAlternativePaymentTokenizationRequest`
for tokenizing alternative payment methods (APMs) or `POAlternativePaymentAuthorizationRequest` for authorizing them.

  * `POAlternativePaymentMethodResponse` has been replaced with ``POAlternativePaymentResponse``.

  * `POAlternativePaymentsService` provides functionality to create a URL for tokenization or authorization. However,
the recommended approach is to use the ``POAlternativePaymentsService/authenticate(using:)`` and/or
``POAlternativePaymentsService/tokenize(request:)`` methods that handle the entire request process, including URL
preparation and the actual redirect.

  * It is no longer possible to process alternative payments using view controllers created by
`POAlternativePaymentMethodViewControllerBuilder` or by the `SFSafariViewController`-based handler defined in the
`ProcessOutUI` module. Instead, use one of the methods in `POAlternativePaymentsService` to handle the payment/tokenization.

### Deprecations

- Previously deprecated declaration were removed:

  * `POTest3DSService` has been replaced by a new `POTest3DSService` defined in the ProcessOutUI module.

  * Legacy API bindings have been removed. Instead, you should use the services and repositories available in
``ProcessOut/ProcessOut/shared`` to interact with the API.

  * `PO3DSRedirectViewControllerBuilder` has been removed, as 3DS redirects are now handled internally by the SDK.

  * `PONativeAlternativePaymentMethodViewControllerBuilder` has been removed. Instead, `import ProcessOutUI` module
and instantiate `PONativeAlternativePaymentView` (or view controller) directly. For additional details, please refer to
the [documentation](https://swiftpackageindex.com/processout/processout-ios/documentation/processoutui/nativealternativepayment).

  * Deprecated protocol aliases with the `Type` suffix have been removed. Please use their counterparts without the
suffix. For example, refer to `POGatewayConfigurationsRepository` instead of `POGatewayConfigurationsRepositoryType`.

## Migrating from versions < 4.11.0

- UI available in `ProcessOut` package is deprecated. `ProcessOutUI` package should be imported instead. Please see
[documentation](https://swiftpackageindex.com/processout/processout-ios/documentation/processoutui) for details.

    - `PONativeAlternativePaymentViewController` should be used instead of
`PONativeAlternativePaymentMethodViewControllerBuilder`. Please note that new module is built on top of SwiftUI
so existing styling is incompatible since no longer relies on UIKit types.

    - `POAlternativePaymentMethodViewControllerBuilder` is deprecated, use `SFSafariViewController` init that accepts
`POAlternativePaymentMethodRequest` directly.

    - `PO3DSRedirectViewControllerBuilder` is deprecated, use `SFSafariViewController` init that accepts
`PO3DSRedirect` directly.

## Migrating from versions < 4.0.0

- `ProcessOutApiType` protocol was removed, instead ``ProcessOut/ProcessOut`` class should be used directly.

- `POImagesRepository` and `POLogger` are no longer part of public interface and can't be accessed from `ProcessOut`
shared instance.

- `POAnyEncodable` utility was removed.

- `PO3DSRedirectViewControllerBuilder`, `PONativeAlternativePaymentMethodViewControllerBuilder` and
`POAlternativePaymentMethodViewControllerBuilder` should be created via init and configured with instance methods.
Static factory methods were deprecated.

- `POInputFormStyle` was replaced with `POInputStyle`. It no longer holds information about title and description
and solely describes input field.

- `POBackgroundDecorationStyle` style was removed.

- `PONativeAlternativePaymentMethodStyle` was revorked.

    - Instead of specifing input's title and description style via `POInputFormStyle`, `sectionTitle` and
`errorDescription` properties should be used.

    - `primaryButton` and `secondaryButton` along with other properties describing actions style are now living in
`PONativeAlternativePaymentMethodActionsStyle`.

    - Background style is defined by `PONativeAlternativePaymentMethodBackgroundStyle`.

-  It is now mandatory to notify SDK about incoming deep links by calling `ProcessOut.shared.processDeepLink(url: url)`
method.

- It is now mandatory to pass return url via `func with(returnUrl: URL)` when using `PO3DSRedirectViewControllerBuilder`
or `POAlternativePaymentMethodViewControllerBuilder`.

## Migrating from versions < 3.0.0

- Instead of `ProcessOut.Setup(projectId: String)` there is new method that should be used to configure
SDK ``ProcessOut/configure(configuration:force:).

- `ProcessOut` was renamed to `ProcessOutLegacyApi` to avoid shadowing module name as it may cause issues. For more
information, see [Swift Issue](https://github.com/apple/swift/issues/56573).

- `CustomerRequest`, `CustomerTokenRequest`, `Invoice`, `WebViewReturn`, `ApiResponse` and deprecated declarations
were removed.
