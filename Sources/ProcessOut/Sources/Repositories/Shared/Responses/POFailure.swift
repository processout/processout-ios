//
//  POFailure.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.10.2022.
//

// swiftlint:disable file_length

import Foundation

/// Information about an error that occurred.
public struct POFailure: Error {

    public struct InvalidField: Decodable, Sendable {

        /// Field name.
        public let name: String

        /// Message describing an error.
        public let message: String

        @_spi(PO)
        public init(name: String, message: String) {
            self.name = name
            self.message = message
        }
    }

    public enum InternalCode: String, Sendable {
        case gateway = "gateway-internal-error"
        case mobile = "processout-mobile.internal"
    }

    public enum TimeoutCode: String, Sendable {
        case gateway = "gateway.timeout"
        case mobile = "processout-mobile.timeout"
    }

    public enum ValidationCode: String, Sendable {
        case general                   = "request.validation.error"
        case gateway                   = "gateway.validation-error"
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

    public enum NotFoundCode: String, Sendable {
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

    public enum AuthenticationCode: String, Sendable {
        case invalid          = "request.authentication.invalid"
        case invalidProjectId = "request.authentication.invalid-project-id"
    }

    public enum GenericCode: String, Sendable {

        /// The card limits were reached (ex: amounts, transactions volume) and the customer should contact its bank.
        case cardExceededLimits = "card.exceeded-limits"

        /// The card CVC check failed
        case cardFailedCvc = "card.failed-cvc"

        /// The card holder bank could not process the payment
        case cardIssuerDown = "card.issuer-down"

        /// The card holder bank failed to process the transaction.
        case cardIssuerFailed = "card.issuer-failed"

        /// The card has no money left in its bank account, the customer should add more funds.
        case cardNoMoney = "card.no-money"

        /// The card is not authorized to make the payment.
        case cardNotAuthorized = "card.not-authorized"

        /// The gateway that attempted to process the payment returned a generic decline. This can be caused by
        /// validation errors, fraud prevention tool or other specific errors.
        case gatewayDeclined = "gateway.declined"

        /// Gateway encountered an unknown error.
        case gatewayUnknownError = "gateway.unknown-error"

        /// Some error happend on SDK's side while processing request.
        case mobile = "processout-mobile.generic.error"

        /// Something is wrong with request (for example malformed request syntax). Seeing this error usually means that
        /// something is wrong with SDK's implementation.
        case requestBadFormat = "request.bad-format"

        /// The card provided as a source was already used elsewhere (to create a token or capture a payment) and
        /// cannot be used twice. If you want to be able to re-use a card token, you must create a customer token
        /// with the card specified as the source.
        case requestCardAlreadyUsed = "request.source.card-already-used"

        /// The card was invalid (invalid number/expiration date/CVC).
        case requestInvalidCard = "request.card.invalid"

        /// Requested resource details could not be expanded.
        case requestInvalidExpand = "request.expand.invalid"

        /// Specified filter is not supported.
        case requestInvalidFilter = "request.filter.invalid"

        /// The request has been accepted for processing, but the processing has not been completed.
        case requestStillProcessing = "request.still-processing"

        /// The user has sent too many requests in a given amount of time.
        case requestTooMuch = "request.too-much"

        /// The payment was declined, but no further information was returned.
        case paymentDeclined = "payment.declined"

        /// The card requires a 3DS authentication to be performed, for example in the scope of 3DS2/SCA.
        case cardNeedsAuthentication = "card.needs-authentication"

        /// Similarly to payment.declined, the card payment was declined with no further information.
        case cardDeclined = "card.declined"

        /// Do Not Honor is the default error code sent by bank, without any additional information.
        case cardDoNotHonor = "card.do-not-honor"

        /// No action was done by the payment provider, and should be retried.
        case cardNoActionTaken = "card.no-action-taken"

        /// The payment should be retried.
        case cardPleaseRetry = "card.please-retry"

        /// The transaction represented a security threat during its processing and was declined.
        case cardSecurityViolation = "card.security-violation"

        /// The acquirer used by the payment processor failed to process the transaction.
        case cardAcquirerFailed = "card.acquirer-failed"

        /// The processing failed at the acquirer or card holder bank level.
        case cardProcessingError = "card.processing-error"

        /// The card maximum payment attempts were reached, the customer should contact its bank.
        case cardMaximumAttempts = "card.maximum-attempts"

        /// The card holder bank declined the payment, and should be contacted by your customer.
        case cardContactBank = "card.contact-bank"

        /// The card withdrawal limit was reached, the customer should contact its bank.
        case cardExceededWithdrawalLimit = "card.exceeded-withdrawal-limit"

        /// The card activity limit was reached, the customer should contact its bank.
        case cardExceededActivityLimits = "card.exceeded-activity-limits"

        /// The transaction had high chances of being a duplicate, and was declined.
        case cardDuplicate = "card.duplicate"

        /// The payment provider could not find the card issuer bank.
        case cardIssuerNotFound = "card.issuer-not-found"

        /// The payment provider failed to contact the card network to process the transaction.
        case cardNetworkFailed = "card.network-failed"

        /// The card is not supported by the payment provider.
        case cardNotSupported = "card.not-supported"

        /// The currency is not supported by this card.
        case cardCurrencyUnsupported = "card.currency-unsupported"

        /// The card type was not supported by the payment provider.
        case cardTypeNotSupported = "card.type-not-supported"

        /// The card was not activated yet by the card holder or its bank.
        case cardNotActivated = "card.not-activated"

        /// The card was expired.
        case cardExpired = "card.expired"

        /// The card was invalid (invalid number/expiration date/CVC).
        case cardInvalid = "card.invalid"

        /// The card has an invalid number.
        case cardInvalidNumber = "card.invalid-number"

        /// The card PIN was invalid. This error code does not apply for online payments.
        case cardInvalidPin = "card.invalid-pin"

        /// The name on the card was invalid (potential AVS failure).
        case cardInvalidName = "card.invalid-name"

        /// The card expiration date was invalid.
        case cardInvalidExpiryDate = "card.invalid-expiry-date"

        /// The card expiration month was invalid.
        case cardInvalidExpiryMonth = "card.invalid-expiry-month"

        /// The card expiration year was invalid.
        case cardInvalidExpiryYear = "card.invalid-expiry-year"

        /// The card holder ZIP code was invalid (potential AVS failure).
        case cardInvalidZip = "card.invalid-zip"

        /// The card holder address was invalid (potential AVS failure).
        case cardInvalidAddress = "card.invalid-address"

        /// The card CVC was missing, but needed to process the payment.
        case cardMissingCvc = "card.missing-cvc"

        /// Invalid CVC.
        case cardInvalidCvc = "card.invalid-cvc"

        /// The card expiry date was missing, but needed to process the payment.
        case cardMissingExpiry = "card.missing-expiry"

        /// The card number was missing.
        case cardMissingNumber = "card.missing-number"

        /// The card 3DS verification process was missing but needed to process the payment.
        case cardMissing3DS = "card.missing-3ds"

        /// The card AVS check failed.
        case cardFailedAvs = "card.failed-avs"

        /// The card AVS check failed on the postal code.
        case cardFailedAvsPostal = "card.failed-avs-postal"

        /// The card does not support 3DS authentication (but a 3DS authentication was requested).
        case cardUnsupported3DS = "card.unsupported-3ds"

        /// The transaction was blocked from authorization due to the 3DS transaction status being in
        /// the authenticating phase.
        case cardPending3DS = "card.pending-3ds"

        /// The card 3DS check failed.
        case cardFailed3DS = "card.failed-3ds"

        /// The card 3DS check expired and needs to be retried.
        case cardExpired3DS = "card.expired-3ds"

        /// The card AVS check failed on the address.
        case cardFailedAvsAddress = "card.failed-avs-address"

        /// Both the card CVC and AVS checks failed.
        case cardFailedCvcAndAvs = "card.failed-cvc-and-avs"

        /// The track data of the card was invalid (expiration date or CVC).
        case cardBadTrackData = "card.bad-track-data"

        /// The card was not yet registered and can therefore not process payments.
        case cardNotRegistered = "card.not-registered"

        /// The card was stolen.
        case cardStolen = "card.stolen"

        /// The card was lost by its card holder.
        case cardLost = "card.lost"

        /// The payment should not be retried.
        case cardDontRetry = "card.dont-retry"

        /// The card bank account was invalid, the customer should contact its bank.
        case cardInvalidAccount = "card.invalid-account"

        /// The card was revoked.
        case cardRevoked = "card.revoked"

        /// All the card holder cards were revoked.
        case cardRevokedAll = "card.revoked-all"

        /// The card was a test card and can't be used to process live transactions.
        case cardTest = "card.test"

        /// The card was blacklisted from the payment provider
        case cardBlacklisted = "card.blacklisted" // swiftlint:disable:this inclusive_language

        /// The transaction has been blocked by ProcessOut for compliance reasons
        case requestTransactionBlocked = "request.transaction-blocked"

        case requestGatewayNotAvailable          = "request.gateway.not-available"
        case requestGatewayOperationNotSupported = "request.gateway.operation-not-supported"
        case requestInvalidIdempotency           = "request.idempotency-key.invalid"
        case requestInvalidPagination            = "request.pagination.invalid"
        case requestInvalidSource                = "request.source.invalid"
        case requestNoGatewayConfiguration       = "request.configuration.missing-gateway-configuration"
        case requestRateExceeded                 = "request.rate.exceeded"
        case resourceNotLinked                   = "resource.not-linked"
        case routingRulesTransactionBlocked      = "routing-rules.transaction-blocked"
        case sandboxNotSupported                 = "sandbox.not-supported"
        case serviceNotSupported                 = "service.not-supported"
    }

    public enum Code: Hashable, Sendable {

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

        /// Unknown error that can't be interpreted. Inspect associated `rawValue` for additional info.
        case unknown(rawValue: String)
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
            return unknownCode
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

extension POFailure: CustomDebugStringConvertible {

    public var debugDescription: String {
        let parameters = [
            ("code", code.rawValue),
            ("message", message),
            ("underlyingError", underlyingError.map(String.init(describing:)))
        ]
        let parametersDescription = parameters
            .compactMap { name, value -> String? in
                guard let value else {
                    return nil
                }
                return "\(name): '\(value)'"
            }
            .joined(separator: ", ")
        return "POFailure(\(parametersDescription))"
    }
}

// swiftlint:enable file_length
