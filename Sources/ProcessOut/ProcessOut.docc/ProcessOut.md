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
- <doc:Localizations>
- <doc:MigrationGuides>

### Errors

All errors that could happen as a result of interaction with the SDK are represented by ``POFailure`` type.

- ``POFailure``

### 3D Secure

- <doc:3DS>
- ``PO3DSService``
- ``PO3DS2Configuration``
- ``PO3DS2AuthenticationRequestParameters``
- ``PO3DS2ChallengeParameters``
- ``PO3DS2ChallengeResult``
- ``PO3DS2AuthenticationRequest``
- ``PO3DS2Challenge``

### Cards

- ``POCardsService``
- ``POCardTokenizationRequest``
- ``POApplePayCardTokenizationRequest``
- ``POContact``
- ``POCard``
- ``POCardUpdateRequest``
- ``POCardIssuerInformation``
- ``POCardCvcCheck``
- ``POCardScheme``

### Customer Tokens

- ``POCustomerTokensService``
- ``POAssignCustomerTokenRequest``
- ``POCustomerToken``

### Gateway Configurations

- ``POGatewayConfigurationsRepository``
- ``POAllGatewayConfigurationsResponse``
- ``POAllGatewayConfigurationsRequest``
- ``POFindGatewayConfigurationRequest``
- ``POGatewayConfiguration``

### Invoices

- ``POInvoicesService``
- ``POInvoiceRequest``
- ``POInvoice``
- ``POInvoiceAuthorizationRequest``
- ``PONativeAlternativePaymentCaptureRequest``
- ``PONativeAlternativePaymentMethodParameter``
- ``PONativeAlternativePaymentMethodRequest``
- ``PONativeAlternativePaymentMethodResponse``
- ``PONativeAlternativePaymentMethodTransactionDetails``
- ``PONativeAlternativePaymentMethodTransactionDetailsRequest``
- ``PONativeAlternativePaymentMethodParameterValues``
- ``PONativeAlternativePaymentMethodState``
<!--- ``PODynamicCheckoutPaymentMethod``-->

### Alternative Payments

- ``POAlternativePaymentsService``
- ``POAlternativePaymentAuthorizationRequest``
- ``POAlternativePaymentTokenizationRequest``
- ``POAlternativePaymentResponse``

### Images Utils

- ``POImageRemoteResource``
- ``POStringCodableColor``

### Utils

- ``POPaginationOptions``
- ``POCancellable``
- ``POStringCodableDecimal``
- ``POStringCodableOptionalDecimal``
- ``POStringDecodableMerchantCapability``
- ``POBillingAddressCollectionMode``
- ``PORepository``
- ``POService``
