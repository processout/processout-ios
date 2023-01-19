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

- ``ProcessOutApi``
- ``ProcessOutApiConfiguration``
- ``ProcessOutApiType``

### Errors

All errors that could happen as a result of interaction with the SDK are representd by ``POFailure`` type.

- ``POFailure``

### Native Alternative Payment Method UI

- <doc:NativeAlternativePaymentMethod>
- ``PONativeAlternativePaymentMethodViewControllerBuilder``
- ``PONativeAlternativePaymentMethodStyle``
- ``PONativeAlternativePaymentMethodUiConfiguration``

### Alternative Payment Method

- ``POAlternativePaymentMethodsServiceType``
-  ``POAlternativePaymentMethodRequest``
-  ``POAlternativePaymentMethodResponse``

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

### Gateway Configurations

- ``POGatewayConfigurationsRepositoryType``
- ``POAllGatewayConfigurationsResponse``
- ``POAllGatewayConfigurationsRequest``
- ``POFindGatewayConfigurationRequest``
- ``POGatewayConfiguration``

### Invoices

- ``POInvoicesServiceType``
- ``PONativeAlternativePaymentCaptureRequest``
- ``PONativeAlternativePaymentMethodParameter``
- ``PONativeAlternativePaymentMethodRequest``
- ``PONativeAlternativePaymentMethodResponse``
- ``PONativeAlternativePaymentMethodTransactionDetails``
- ``PONativeAlternativePaymentMethodTransactionDetailsRequest``
- ``PONativeAlternativePaymentMethodState``

### Images

- ``POImagesRepositoryType``

### Utils

- ``POPaginationOptions``
- ``POCancellableType``
- ``POAnyEncodable``
- ``POImmutableExcludedCodable``
- ``POImmutableStringCodableDecimal``
- ``POImmutableStringCodableOptionalDecimal``
- ``PORepositoryType``
- ``POServiceType``
- ``POAutoAsync``

### Legacy Declarations

There are outdated declaration that only exist for backward compatibility with old SDK, they will be removed when
full feature parity is reached. See ``ProcessOutLegacyApi`` for possible methods.

- ``ProcessOutLegacyApi``
- ``TokenRequest``
- ``AuthorizationRequest``
- ``GatewayConfiguration``
- ``APMTokenReturn``
- ``ThreeDSHandler``
- ``ThreeDSFingerprintResponse``
- ``CustomerAction``
- ``DirectoryServerData``
- ``AuthentificationChallengeData``
- ``ProcessOutWebView``
- ``FingerPrintWebViewSchemeHandler``
- ``ProcessOutException``
