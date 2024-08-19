# Migration Guides

## Migrating from versions < 5.0.0

### 3D Secure

- Web-based 3DS redirects are now handled internally by the SDK, making the related UI components no longer accessible.
This includes:

  * `PO3DSRedirectController`.

  * `SFSafariViewController` extension for creating it with `PO3DSRedirect`.

  * `POWebAuthenticationSession` extension for creating it with `PO3DSRedirect`.

- The ``POTest3DSService`` no longer requires a `returnUrl`. However, you must ensure that the return URL assigned to
the invoice is a valid deep link that your application can handle.

### Alternative Payment Method

Processing alternative payments using `SFSafariViewController` or `POWebAuthenticationSession` created with 
`POAlternativePaymentMethodRequest` is no longer supported.

Instead, you need to create one of the following requests: `POAlternativePaymentTokenizationRequest` or
`POAlternativePaymentAuthorizationRequest`, and then pass it to the `POAlternativePaymentsService`, which is directly
accessible via `ProcessOut.shared.alternativePayments`.

### Web Authentication

The `POWebAuthenticationSession` and the related `POWebAuthenticationSessionCallback` have been removed. These were
previously used to handle 3DS redirects and alternative payments, but this functionality is now part of the internal
implementation and is no longer exposed publicly.

### Native APM

- Deprecated aliases have been removed. Please use their counterparts without the `Method` suffix. This change affects:

  * `PONativeAlternativePaymentMethodDelegate`
  * `PONativeAlternativePaymentMethodConfiguration`
  * `PONativeAlternativePaymentMethodEvent`

- Deprecated `waitsPaymentConfirmation`, `paymentConfirmationTimeout`, and `paymentConfirmationSecondaryAction` are no
longer part of `PONativeAlternativePaymentConfiguration`. Instead these can now be set and accessed via the
``PONativeAlternativePaymentConfiguration/paymentConfirmation`` object.

- ``PONativeAlternativePaymentDelegate`` methods have also been updated:

  * `func nativeAlternativePaymentDidEmitEvent(_ event:)` has been replaced by
``PONativeAlternativePaymentDelegate/nativeAlternativePayment(didEmitEvent:)``.

  * `func nativeAlternativePaymentDefaultValues(for:completion:)` has been replaced by
``PONativeAlternativePaymentDelegate/nativeAlternativePayment(defaultsFor:)``. Additionally this method no longer
accepts a completion argument and now relies on structured concurrency.

### Card Tokenization

- The method names in ``POCardTokenizationDelegate`` have been updated:

  * `func cardTokenizationDidEmitEvent(_ event:)` is now ``POCardTokenizationDelegate/cardTokenization(didEmitEvent:)``.

  * `func preferredScheme(issuerInformation:)` is now ``POCardTokenizationDelegate/cardTokenization(preferredSchemeFor:)``.
Additionally, this method now expects a typed card scheme to be returned instead of a raw string.

  * `func shouldContinueTokenization(after:)` is now ``POCardTokenizationDelegate/cardTokenization(shouldContinueAfter:)``.

  * `func processTokenizedCard(card:)` is now ``POCardTokenizationDelegate/cardTokenization(didTokenizeCard:)``.

- The deprecated `POBillingAddressConfiguration/CollectionMode` has been removed. Instead, use
`POBillingAddressCollectionMode` directly.

### Card Update

- The method names in ``POCardUpdateDelegate`` have been updated:

  * `func cardInformation(cardId:)` is now ``POCardUpdateDelegate/cardUpdate(informationFor:)``.

  * `func shouldContinueUpdate(after:)` is now ``POCardUpdateDelegate/cardUpdate(shouldContinueAfter:)``.

  * `func cardUpdateDidEmitEvent(:)` is now ``POCardUpdateDelegate/cardUpdate(didEmitEvent:)``.

- ``POCardUpdateInformation`` no longer uses raw strings to represent `scheme`, `coScheme`, and `preferredScheme`. These
are now represented by `POCardScheme`.
