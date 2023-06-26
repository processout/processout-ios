# Migration Guides

## Migrating from versions < 4.0.0

- `ProcessOutApiType` protocol was removed, instead ``ProcessOut/ProcessOut`` class should be used directly.

- `POImagesRepository` and `POLogger` are no longer part of public interface and can't be accessed from `ProcessOut`
shared instance.

- `POAnyEncodable` utility was removed.

- ``PO3DSRedirectViewControllerBuilder``, ``PONativeAlternativePaymentMethodViewControllerBuilder`` and
``POAlternativePaymentMethodViewControllerBuilder`` should be created via init and configured with instance methods.
Static factory methods were deprecated.

- `POInputFormStyle` was replaced with ``POInputStyle``. It no longer holds information about title and description
and solely describes input field.

- `POBackgroundDecorationStyle` style was removed.

- ``PONativeAlternativePaymentMethodStyle`` was revorked.

    - Instead of specifing input's title and description style via `POInputFormStyle`, `sectionTitle` and
`errorDescription` properties should be used.

    - `primaryButton` and `secondaryButton` along with other properties describing actions style are now living in
`PONativeAlternativePaymentMethodActionsStyle`.

    - Background style is defined by ``PONativeAlternativePaymentMethodBackgroundStyle``.

-  It is now mandatory to notify SDK about incoming deep links by calling `ProcessOut.shared.processDeepLink(url: url)`
method.

- It is now mandatory to pass return url via `func with(returnUrl: URL)` when using ``PO3DSRedirectViewControllerBuilder``
or ``POAlternativePaymentMethodViewControllerBuilder``.

## Migrating from versions < 3.0.0

- Instead of `ProcessOut.Setup(projectId: String)` there is new method that should be used to configure
SDK ``ProcessOut/configure(configuration:)``.

- `ProcessOut` was renamed to ``ProcessOutLegacyApi`` to avoid shadowing module name as it may cause issues. For more
information, see [Swift Issue](https://github.com/apple/swift/issues/56573).

- `CustomerRequest`, `CustomerTokenRequest`, `Invoice`, `WebViewReturn`, `ApiResponse` and deprecated declarations
were removed.
