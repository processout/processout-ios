# ``ProcessOut``

## Overview

Before using ProcessOut SDK make sure to configure it.

```swift
import ProcessOut

let configuration = ProcessOutConfiguration.production(projectId: "your_project_id")
ProcessOut.configure(configuration: configuration)
```

## Topics

### Framework

- ``ProcessOut/ProcessOut``
- ``ProcessOutConfiguration``
- ``ProcessOutApi``
- ``ProcessOutApiConfiguration``
- <doc:Localizations>
- <doc:MigrationGuides>

### Errors

All errors that could happen as a result of interaction with the SDK are represented by ``POFailure`` type.

- ``POFailure``
- ``POFailureCode``

### 3DS

- <doc:3DS>
- ``PO3DS2Service``
- ``PO3DS2Configuration``
- ``PO3DS2ConfigurationCardScheme``
- ``PO3DS2AuthenticationRequestParameters``
- ``PO3DS2ChallengeParameters``
- ``PO3DS2ChallengeResult``
- ``PO3DSServiceType``
- ``PO3DSService``
- ``PO3DS2AuthenticationRequest``
- ``PO3DS2Challenge``
- ``PO3DSRedirect``
- ``PO3DSRedirectViewControllerBuilder``
- ``POTest3DSService``

### Native Alternative Payment Method

- <doc:NativeAlternativePaymentMethod>
- ``PONativeAlternativePaymentMethodViewControllerBuilder``
- ``PONativeAlternativePaymentMethodStyle``
- ``PONativeAlternativePaymentMethodActionsStyle``
- ``PONativeAlternativePaymentMethodBackgroundStyle``
- ``PONativeAlternativePaymentMethodConfiguration``
- ``PONativeAlternativePaymentMethodEvent``
- ``PONativeAlternativePaymentMethodDelegate``

### Alternative Payments

- ``POAlternativePaymentsService``
- ``POAlternativePaymentAuthorizationRequest``
- ``POAlternativePaymentTokenizationRequest``
- ``POAlternativePaymentAuthenticationRequest``
- ``POAlternativePaymentResponse``
- ``POAlternativePaymentMethodsService``
- ``POAlternativePaymentMethodsServiceType``
- ``POAlternativePaymentMethodRequest``
- ``POAlternativePaymentMethodResponse``
- ``POAlternativePaymentMethodViewControllerBuilder``

### Cards

- ``POCardsService``
- ``POCardTokenizationRequest``
- ``POApplePayPaymentTokenizationRequest``
- ``POApplePayCardTokenizationRequest``
- ``POApplePayTokenizationRequest``
- ``POApplePayTokenizationDelegate``
- ``POContact``
- ``POCard``
- ``POCardUpdateRequest``
- ``POCardIssuerInformation``
- ``POCardCvcCheck``
- ``POCardScheme``
- ``POCardsServiceType``

### Customer Tokens

- ``POCustomerTokensService``
- ``POAssignCustomerTokenRequest``
- ``POCustomerToken``
- ``POCustomerTokenType``
- ``POCustomerTokensServiceType``
- ``PODeleteCustomerTokenRequest``
- ``PONativeAlternativePaymentTokenizationRequestV2``
- ``PONativeAlternativePaymentTokenizationResponseV2``
- ``PONativeAlternativePaymentSubmitDataV2``
- ``PONativeAlternativePaymentStateV2``
- ``PONativeAlternativePaymentMethodV2``
- ``PONativeAlternativePaymentInvoiceV2``
- ``PONativeAlternativePaymentElementV2``
- ``PONativeAlternativePaymentFormV2``
- ``PONativeAlternativePaymentInstructionsGroupV2``
- ``PONativeAlternativePaymentRedirectV2``
- ``PONativeAlternativePaymentCustomerInstructionV2``

### Gateway Configurations

- ``POGatewayConfigurationsRepository``
- ``POAllGatewayConfigurationsResponse``
- ``POAllGatewayConfigurationsRequest``
- ``POFindGatewayConfigurationRequest``
- ``POGatewayConfiguration``
- ``POGatewayConfigurationsRepositoryType``

### Invoices

- ``POInvoicesService``
- ``POInvoiceRequest``
- ``POInvoice``
- ``POTransaction``
- ``POTransactionStatus``
- ``POInvoiceAuthorizationRequest``
- ``PONativeAlternativePaymentCaptureRequest``
- ``PONativeAlternativePaymentMethodParameter``
- ``PONativeAlternativePaymentMethodRequest``
- ``PONativeAlternativePaymentMethodResponse``
- ``PONativeAlternativePaymentMethodTransactionDetails``
- ``PONativeAlternativePaymentMethodTransactionDetailsRequest``
- ``PONativeAlternativePaymentMethodParameterValues``
- ``PONativeAlternativePaymentMethodState``
- ``PONativeAlternativePaymentAuthorizationRequestV2``
- ``PONativeAlternativePaymentAuthorizationResponseV2``
- ``PONativeAlternativePaymentSubmitDataV2``
- ``PONativeAlternativePaymentStateV2``
- ``PONativeAlternativePaymentMethodV2``
- ``PONativeAlternativePaymentInvoiceV2``
- ``PONativeAlternativePaymentElementV2``
- ``PONativeAlternativePaymentFormV2``
- ``PONativeAlternativePaymentInstructionsGroupV2``
- ``PONativeAlternativePaymentRedirectV2``
- ``PONativeAlternativePaymentCustomerInstructionV2``

- ``PODynamicCheckoutPaymentMethod``
- ``POInvoicesServiceType``

### Appearance

Types that describe properties such as shadow and border. And style of higher level components, for example buttons and inputs.

- ``POShadowStyle``
- ``POBorderStyle``
- ``POTypography``
- ``POTextStyle``
- ``POInputStyle``
- ``POInputStateStyle``
- ``PORadioButtonStyle``
- ``PORadioButtonStateStyle``
- ``PORadioButtonKnobStateStyle``
- ``POButtonStyle``
- ``POButtonStateStyle``
- ``POActivityIndicatorStyle``
- ``POActivityIndicatorView``
- ``POActionsContainerStyle``
- ``POTextFieldStyle``
- ``POActivityIndicatorViewType``

### Visual Utils

- ``POImageRemoteResource``
- ``POStringCodableColor``
- ``POBarcode``

### Utils

- ``POWebAuthenticationCallback``
- ``POPaginationOptions``
- ``POCancellable``
- ``POTypedRepresentation``
- ``POBillingAddressCollectionMode``
- ``PORepository``
- ``POService``
- ``POCancellableType``
- ``PORepositoryType``
- ``POServiceType``
- ``POAutoAsync``
- ``POAutoCompletion``

### Coding Utils

- ``POImmutableExcludedCodable``
- ``POImmutableStringCodableDecimal``
- ``POImmutableStringCodableOptionalDecimal``
- ``POFallbackDecodable``
- ``POFallbackValueProvider``
- ``POEmptyStringProvider``
- ``POStringDecodableMerchantCapability``
- ``POCodablePassKitPaymentNetworks``
- ``POExcludedEncodable``

### Legacy Declarations

There are outdated declaration that only exist for backward compatibility with old SDK, they will be removed when
full feature parity is reached. See ``ProcessOutLegacyApi`` for possible methods.

- ``ProcessOutLegacyApi``
- ``TokenRequest``
- ``AuthorizationRequest``
- ``GatewayConfiguration``
- ``APMTokenReturn``
- ``ThreeDSHandler``
- ``ThreeDSTestHandler``
- ``ThreeDSFingerprintResponse``
- ``CustomerAction``
- ``DirectoryServerData``
- ``AuthentificationChallengeData``
- ``ProcessOutWebView``
- ``FingerPrintWebViewSchemeHandler``
- ``ProcessOutException``
