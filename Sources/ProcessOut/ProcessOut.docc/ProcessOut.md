# ``ProcessOut``

## Overview

Before using ProcessOut SDK make sure to configure it.

```swift
import ProcessOut

let configuration = ProcessOutApiConfiguration.production(projectId: "your_project_id")
ProcessOutApi.configure(configuration: configuration)
```

## Topics

### Framework

- <doc:MigratingFromProcessOut2>
- <doc:Localizations>
- ``ProcessOutApi``
- ``ProcessOutApiConfiguration``
- ``ProcessOutApiType``

### Errors

All errors that could happen as a result of interaction with the SDK are representd by ``POFailure`` type.

- ``POFailure``

### 3DS

- <doc:3DS>
- ``PO3DSService``
- ``PO3DS2Configuration``
- ``PO3DS2AuthenticationRequest``
- ``PO3DS2Challenge``
- ``PO3DSRedirect``
- ``PO3DSRedirectViewControllerBuilder``

### Native Alternative Payment Method

- <doc:NativeAlternativePaymentMethod>
- ``PONativeAlternativePaymentMethodViewControllerBuilder``
- ``PONativeAlternativePaymentMethodStyle``
- ``PONativeAlternativePaymentMethodConfiguration``
- ``PONativeAlternativePaymentMethodEvent``
- ``PONativeAlternativePaymentMethodDelegate``

### Alternative Payment Method

- ``POAlternativePaymentMethodViewControllerBuilder``
- ``POAlternativePaymentMethodsService``
- ``POAlternativePaymentMethodRequest``
- ``POAlternativePaymentMethodResponse``

### Cards

- ``POCardsService``
- ``POCardTokenizationRequest``
- ``POApplePayCardTokenizationRequest``
- ``POContact``
- ``POCard``
- ``POCardUpdateRequest``

### Customer Tokens

- ``POCustomerTokensService``
- ``POAssignCustomerTokenRequest``
- ``POCustomerToken``

### Gateway Configurations

- ``POGatewayConfigurationsRepositoryType``
- ``POAllGatewayConfigurationsResponse``
- ``POAllGatewayConfigurationsRequest``
- ``POFindGatewayConfigurationRequest``
- ``POGatewayConfiguration``

### Invoices

- ``POInvoicesService``
- ``POInvoiceAuthorizationRequest``
- ``PONativeAlternativePaymentCaptureRequest``
- ``PONativeAlternativePaymentMethodParameter``
- ``PONativeAlternativePaymentMethodRequest``
- ``PONativeAlternativePaymentMethodResponse``
- ``PONativeAlternativePaymentMethodTransactionDetails``
- ``PONativeAlternativePaymentMethodTransactionDetailsRequest``
- ``PONativeAlternativePaymentMethodState``

### Images

- ``POImagesRepositoryType``

### Appearance

Types that describe properties such as shadow and border. And style of higher level components, for example buttons and inputs.

- ``POShadowStyle``
- ``POBorderStyle``
- ``POTypography``
- ``POTextStyle``
- ``POInputFormStyle``
- ``POInputFormStateStyle``
- ``POTextFieldStyle``
- ``POButtonStyle``
- ``POButtonStateStyle``
- ``POActivityIndicatorStyle``
- ``POActivityIndicatorViewType``
- ``POBackgroundDecorationStateStyle``
- ``POBackgroundDecorationStyle``

### Utils

- ``POPaginationOptions``
- ``POCancellableType``
- ``POAnyEncodable``
- ``POImmutableExcludedCodable``
- ``POImmutableStringCodableDecimal``
- ``POImmutableStringCodableOptionalDecimal``
- ``PORepositoryType``
- ``POService``
- ``POAutoAsync``
- ``POLogger``

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
