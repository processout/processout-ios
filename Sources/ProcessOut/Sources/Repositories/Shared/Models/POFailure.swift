//
//  POFailure.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.10.2022.
//

import Foundation

/// Information about an error that occurred.
public struct POFailure: Error {

    public struct InvalidField: Decodable {

        /// Field name.
        public let name: String

        /// Message describing an error.
        public let message: String
    }

    public enum InternalCode: String {
        case gateway = "gateway-internal-error"
        case mobile = "processout-mobile.internal"
    }

    public enum TimeoutCode: String {
        case gateway = "gateway.timeout"
        case mobile = "processout-mobile.timeout"
    }

    public enum ValidationCode: String {
        case general                   = "request.validation.error"
        case invalidAddress            = "request.validation.invalid-address"
        case invalidAmount             = "request.validation.invalid-amount"
        case invalidChallengeIndicator = "request.validation.invalid-challenge-indicator"
        case invalidCountry            = "request.validation.invalid-country"
        case invalidCurrency           = "request.validation.invalid-currency"
        case invalidCustomerInput      = "gateway.invalid-customer-input"
        case invalidDate               = "request.validation.invalid-date"
        case invalidDescription        = "request.validation.invalid-description"
        case invalidDetailCategory     = "request.validation.invalid-detail-category"
        case invalidDetailCondition    = "request.validation.invalid-detail-condition"
        case invalidDeviceChannel      = "request.validation.invalid-device-channel"
        case invalidDuration           = "request.validation.invalid-duration"
        case invalidEmail              = "request.validation.invalid-email"
        case invalidExemptionReason    = "request.validation.invalid-exemption-reason"
        case invalidExternalFraudTools = "request.validation.invalid-external-fraud-tools"
        case invalidGatewayData        = "request.validation.invalid-gateway-data"
        case invalidId                 = "request.validation.invalid-id"
        case invalidIpAddress          = "request.validation.invalid-ip-address"
        case invalidLegalDocument      = "request.validation.invalid-legal-document"
        case invalidMetadata           = "request.validation.invalid-metadata"
        case invalidName               = "request.validation.invalid-name"
        case invalidPaymentType        = "request.validation.invalid-payment-type"
        case invalidPercent            = "request.validation.invalid-percent"
        case invalidPhoneNumber        = "request.validation.invalid-phone-number"
        case invalidQuantity           = "request.validation.invalid-quantity"
        case invalidRelationship       = "request.validation.invalid-relationship"
        case invalidRelayStoreName     = "request.validation.invalid-relay-store-name"
        case invalidRole               = "request.validation.invalid-role"
        case invalidSettings           = "request.validation.invalid-settings"
        case invalidSex                = "request.validation.invalid-sex"
        case invalidShippingDelay      = "request.validation.invalid-shipping-delay"
        case invalidShippingMethod     = "request.validation.invalid-shipping-method"
        case invalidState              = "gateway.invalid-state"
        case invalidSubAccount         = "request.validation.invalid-subaccount"
        case invalidTaxAmount          = "request.validation.invalid-tax-amount"
        case invalidTaxRate            = "request.validation.invalid-tax-rate"
        case invalidType               = "request.validation.invalid-type"
        case invalidUrl                = "request.validation.invalid-url"
        case invalidUser               = "request.validation.invalid-user"
        case missingCurrency           = "request.validation.missing-currency"
        case missingCustomerInput      = "gateway.missing-customer-input"
        case missingDescription        = "request.validation.missing-description"
        case missingEmail              = "request.validation.missing-email"
        case missingInvoice            = "request.validation.missing-invoice"
        case missingName               = "request.validation.missing-name"
        case missingSource             = "request.validation.missing-source"
        case missingType               = "request.validation.missing-type"
    }

    public enum NotFoundCode: String {
        case activity                  = "resource.activity.not-found"
        case addon                     = "resource.addon.not-found"
        case alert                     = "resource.alert.not-found"
        case apiKey                    = "resource.api-key.not-found"
        case apiRequest                = "resource.api-request.not-found"
        case apiVersion                = "resource.api-version.not-found"
        case applepayConfiguration     = "resource.applepay-configuration.not-found"
        case board                     = "resource.board.not-found"
        case card                      = "resource.card.not-found"
        case chart                     = "resource.chart.not-found"
        case collaborator              = "resource.collaborator.not-found"
        case country                   = "resource.country.not-found"
        case coupon                    = "resource.coupon.not-found"
        case currency                  = "resource.currency.not-found"
        case customer                  = "resource.customer.not-found"
        case discount                  = "resource.discount.not-found"
        case event                     = "resource.event.not-found"
        case export                    = "resource.export.not-found"
        case fraudServiceConfiguration = "resource.fraud-service-configuration.not-found"
        case gateway                   = "resource.gateway.not-found"
        case gatewayConfiguration      = "resource.gateway-configuration.not-found"
        case general                   = "resource.not-found"
        case invoice                   = "resource.invoice.not-found"
        case payout                    = "resource.payout.not-found"
        case permissionGroup           = "resource.permission-group.not-found"
        case plan                      = "resource.plan.not-found"
        case product                   = "resource.product.not-found"
        case project                   = "resource.project.not-found"
        case refund                    = "resource.refund.not-found"
        case route                     = "request.route-not-found"
        case subscription              = "resource.subscription.not-found"
        case token                     = "resource.token.not-found"
        case tokenizationRequest       = "resource.tokenization-request.not-found"
        case transaction               = "resource.transaction.not-found"
        case user                      = "resource.user.not-found"
        case webhookEndpoint           = "resource.webhook-endpoint.not-found"
    }

    public enum AuthenticationCode: String {
        case invalid          = "request.authentication.invalid"
        case invalidProjectId = "request.authentication.invalid-project-id"
    }

    public enum GenericCode: String {
        case cardExceededLimits                  = "card.exceeded-limits"
        case cardIssuerFailed                    = "card.issuer-failed"
        case cardNoMoney                         = "card.no-money"
        case cardNotAuthorized                   = "card.not-authorized"
        case gatewayDeclined                     = "gateway.declined"
        case requestBadFormat                    = "request.bad-format"
        case requestCardAlreadyUsed              = "request.source.card-already-used"
        case requestGatewayNotAvailable          = "request.gateway.not-available"
        case requestGatewayOperationNotSupported = "request.gateway.operation-not-supported"
        case requestInvalidCard                  = "request.card.invalid"
        case requestInvalidExpand                = "request.expand.invalid"
        case requestInvalidFilter                = "request.filter.invalid"
        case requestInvalidIdempotency           = "request.idempotency-key.invalid"
        case requestInvalidPagination            = "request.pagination.invalid"
        case requestInvalidSource                = "request.source.invalid"
        case requestNoGatewayConfiguration       = "request.configuration.missing-gateway-configuration"
        case requestRateExceeded                 = "request.rate.exceeded"
        case requestStillProcessing              = "request.still-processing"
        case requestTooMuch                      = "request.too-much"
        case resourceNotLinked                   = "resource.not-linked"
        case routingRulesTransactionBlocked      = "routing-rules.transaction-blocked"
        case sandboxNotSupported                 = "sandbox.not-supported"
        case serviceNotSupported                 = "service.not-supported"
    }

    public enum UnknownCode: String {
        case gateway = "gateway.unknown-error"
        case mobile = "processout-mobile.unknown"
    }

    public enum Code: Equatable {

        /// No network connection.
        case networkUnreachable

        /// Request didn't finish in time.
        case timeout(TimeoutCode)

        /// Something went wrong on the ProcessOut side. This is extremely rare.
        case `internal`(InternalCode)

        /// Cancellation error.
        case cancelled

        /// The request contained a field that couldn’t be validated.
        case validation(ValidationCode)

        /// Your API credentials could not be verified.
        case authentication(AuthenticationCode)

        /// The requested resource could not be found.
        case notFound(NotFoundCode)

        /// Generic error that can't be classified as one of the errors above.
        case generic(GenericCode)

        /// Unknown error that can't be interpreted. Inspect `underlyingError` object for additional details.
        case unknown(UnknownCode)
    }

    /// Failure message. Not intented to be used as a user facing string.
    public let message: String?

    /// Failure code.
    public let code: Code

    /// Invalid fields if any.
    public let invalidFields: [InvalidField]?

    /// Underlying error for inspection.
    public let underlyingError: Error?

    /// Creates failure instance.
    public init(
        message: String? = nil, code: Code, invalidFields: [InvalidField]? = nil, underlyingError: Error? = nil
    ) {
        self.message = message
        self.code = code
        self.invalidFields = invalidFields
        self.underlyingError = underlyingError
    }
}

extension POFailure.Code {

    /// Code raw value.
    /// - NOTE: Value is consistent with Android counterpart.
    public var rawValue: String {
        switch self {
        case .networkUnreachable:
            return "processout-mobile.network-unreachable"
        case let .timeout(timeoutCode):
            return timeoutCode.rawValue
        case let .internal(internalCode):
            return internalCode.rawValue
        case .cancelled:
            return "processout-mobile.cancelled"
        case let .unknown(unknownCode):
            return unknownCode.rawValue
        case let .validation(validationCode):
            return validationCode.rawValue
        case let .authentication(authenticationCode):
            return authenticationCode.rawValue
        case let .notFound(notFoundCode):
            return notFoundCode.rawValue
        case let .generic(genericCode):
            return genericCode.rawValue
        }
    }
}
