//
//  POFailureCode.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 05.02.2025.
//

// swiftlint:disable inclusive_language file_length

/// Represents a failure code that describes an error encountered during a request.
public struct POFailureCode: Sendable, Equatable {

    /// The raw string representation of the failure code.
    public let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue.lowercased()
    }
}

public func ~= (pattern: POFailureCode, value: Error?) -> Bool {
    if let failure = value as? POFailure {
        return failure.failureCode == pattern
    }
    return false
}

extension POFailureCode: Codable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.rawValue = try container.decode(String.self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension POFailureCode {

    public enum Authentication {

        /// Invalid authentication details.
        public static let invalid = POFailureCode(rawValue: "request.authentication.invalid")

        /// Invalid project ID.
        public static let invalidProjectId = POFailureCode(rawValue: "request.authentication.invalid-project-id")
    }

    public enum Card {

        /// The card limits were reached (ex: amounts, transactions volume) and the customer should contact its bank.
        public static let exceededLimits = POFailureCode(rawValue: "card.exceeded-limits")

        /// The card CVC check failed
        public static let failedCvc = POFailureCode(rawValue: "card.failed-cvc")

        /// The card holder bank could not process the payment
        public static let issuerDown = POFailureCode(rawValue: "card.issuer-down")

        /// The card holder bank failed to process the transaction.
        public static let issuerFailed = POFailureCode(rawValue: "card.issuer-failed")

        /// The card has no money left in its bank account, the customer should add more funds.
        public static let noMoney = POFailureCode(rawValue: "card.no-money")

        /// The card is not authorized to make the payment.
        public static let notAuthorized = POFailureCode(rawValue: "card.not-authorized")

        /// The card requires a 3DS authentication to be performed, for example in the scope of 3DS2/SCA.
        public static let needsAuthentication = POFailureCode(rawValue: "card.needs-authentication")

        /// Similarly to payment.declined, the card payment was declined with no further information.
        public static let declined = POFailureCode(rawValue: "card.declined")

        /// Error code sent by bank, without any additional information.
        public static let doNotHonor = POFailureCode(rawValue: "card.do-not-honor")

        /// No action was done by the payment provider, and should be retried.
        public static let noActionTaken = POFailureCode(rawValue: "card.no-action-taken")

        /// The payment should be retried.
        public static let pleaseRetry = POFailureCode(rawValue: "card.please-retry")

        /// The transaction represented a security threat during its processing and was declined.
        public static let securityViolation = POFailureCode(rawValue: "card.security-violation")

        /// The acquirer used by the payment processor failed to process the transaction.
        public static let acquirerFailed = POFailureCode(rawValue: "card.acquirer-failed")

        /// The processing failed at the acquirer or card holder bank level.
        public static let processingError = POFailureCode(rawValue: "card.processing-error")

        /// The card maximum payment attempts were reached, the customer should contact its bank.
        public static let maximumAttempts = POFailureCode(rawValue: "card.maximum-attempts")

        /// The card holder bank declined the payment, and should be contacted by your customer.
        public static let contactBank = POFailureCode(rawValue: "card.contact-bank")

        /// The card withdrawal limit was reached, the customer should contact its bank.
        public static let exceededWithdrawalLimit = POFailureCode(rawValue: "card.exceeded-withdrawal-limit")

        /// The card activity limit was reached, the customer should contact its bank.
        public static let exceededActivityLimits = POFailureCode(rawValue: "card.exceeded-activity-limits")

        /// The transaction had high chances of being a duplicate, and was declined.
        public static let duplicate = POFailureCode(rawValue: "card.duplicate")

        /// The payment provider could not find the card issuer bank.
        public static let issuerNotFound = POFailureCode(rawValue: "card.issuer-not-found")

        /// The payment provider failed to contact the card network to process the transaction.
        public static let networkFailed = POFailureCode(rawValue: "card.network-failed")

        /// The card is not supported by the payment provider.
        public static let notSupported = POFailureCode(rawValue: "card.not-supported")

        /// The currency is not supported by this card.
        public static let currencyUnsupported = POFailureCode(rawValue: "card.currency-unsupported")

        /// The card type was not supported by the payment provider.
        public static let typeNotSupported = POFailureCode(rawValue: "card.type-not-supported")

        /// The card was not activated yet by the card holder or its bank.
        public static let notActivated = POFailureCode(rawValue: "card.not-activated")

        /// The card was expired.
        public static let expired = POFailureCode(rawValue: "card.expired")

        /// The card was invalid (invalid number/expiration date/CVC).
        public static let invalid = POFailureCode(rawValue: "card.invalid")

        /// The card has an invalid number.
        public static let invalidNumber = POFailureCode(rawValue: "card.invalid-number")

        /// The card PIN was invalid. This error code does not apply for online payments.
        public static let invalidPin = POFailureCode(rawValue: "card.invalid-pin")

        /// The name on the card was invalid (potential AVS failure).
        public static let invalidName = POFailureCode(rawValue: "card.invalid-name")

        /// The card expiration date was invalid.
        public static let invalidExpiryDate = POFailureCode(rawValue: "card.invalid-expiry-date")

        /// The card expiration month was invalid.
        public static let invalidExpiryMonth = POFailureCode(rawValue: "card.invalid-expiry-month")

        /// The card expiration year was invalid.
        public static let invalidExpiryYear = POFailureCode(rawValue: "card.invalid-expiry-year")

        /// The card holder ZIP code was invalid (potential AVS failure).
        public static let invalidZip = POFailureCode(rawValue: "card.invalid-zip")

        /// The card holder address was invalid (potential AVS failure).
        public static let invalidAddress = POFailureCode(rawValue: "card.invalid-address")

        /// The card CVC was missing, but needed to process the payment.
        public static let missingCvc = POFailureCode(rawValue: "card.missing-cvc")

        /// Invalid CVC.
        public static let invalidCvc = POFailureCode(rawValue: "card.invalid-cvc")

        /// The card expiry date was missing, but needed to process the payment.
        public static let missingExpiry = POFailureCode(rawValue: "card.missing-expiry")

        /// The card number was missing.
        public static let missingNumber = POFailureCode(rawValue: "card.missing-number")

        /// The card 3DS verification process was missing but needed to process the payment.
        public static let missing3DS = POFailureCode(rawValue: "card.missing-3ds")

        /// The card AVS check failed.
        public static let failedAvs = POFailureCode(rawValue: "card.failed-avs")

        /// The card AVS check failed on the postal code.
        public static let failedAvsPostal = POFailureCode(rawValue: "card.failed-avs-postal")

        /// The card does not support 3DS authentication (but a 3DS authentication was requested).
        public static let cardUnsupported3DS = POFailureCode(rawValue: "card.unsupported-3ds")

        /// The transaction was blocked from authorization due to the 3DS transaction status being in
        /// the authenticating phase.
        public static let pending3DS = POFailureCode(rawValue: "card.pending-3ds")

        /// The card 3DS check failed.
        public static let failed3DS = POFailureCode(rawValue: "card.failed-3ds")

        /// The card 3DS check expired and needs to be retried.
        public static let expired3DS = POFailureCode(rawValue: "card.expired-3ds")

        /// The card AVS check failed on the address.
        public static let failedAvsAddress = POFailureCode(rawValue: "card.failed-avs-address")

        /// Both the card CVC and AVS checks failed.
        public static let failedCvcAndAvs = POFailureCode(rawValue: "card.failed-cvc-and-avs")

        /// The track data of the card was invalid (expiration date or CVC).
        public static let badTrackData = POFailureCode(rawValue: "card.bad-track-data")

        /// The card was not yet registered and can therefore not process payments.
        public static let notRegistered = POFailureCode(rawValue: "card.not-registered")

        /// The card was stolen.
        public static let stolen = POFailureCode(rawValue: "card.stolen")

        /// The card was lost by its card holder.
        public static let lost = POFailureCode(rawValue: "card.lost")

        /// The payment should not be retried.
        public static let dontRetry = POFailureCode(rawValue: "card.dont-retry")

        /// The card account was invalid.
        public static let invalidAccount = POFailureCode(rawValue: "card.invalid-account")

        /// The card was revoked.
        public static let revoked = POFailureCode(rawValue: "card.revoked")

        /// All the card holder cards were revoked.
        public static let revokedAll = POFailureCode(rawValue: "card.revoked-all")

        /// The card was a test card and can't be used to process live transactions.
        public static let test = POFailureCode(rawValue: "card.test")

        /// The card was blacklisted from the payment provider
        public static let blacklisted = POFailureCode(rawValue: "card.blacklisted")
    }

    public enum RequestValidation {

        /// A general request validation error occurred.
        public static let general = POFailureCode(rawValue: "request.validation.error")

        /// The provided address is invalid.
        public static let invalidAddress = POFailureCode(rawValue: "request.validation.invalid-address")

        /// The amount specified is invalid.
        public static let invalidAmount = POFailureCode(rawValue: "request.validation.invalid-amount")

        /// The challenge indicator value is invalid.
        public static let invalidChallengeIndicator = POFailureCode(
            rawValue: "request.validation.invalid-challenge-indicator"
        )

        /// The provided country code is invalid.
        public static let invalidCountry = POFailureCode(rawValue: "request.validation.invalid-country")

        /// The specified currency is invalid.
        public static let invalidCurrency = POFailureCode(rawValue: "request.validation.invalid-currency")

        /// The provided date format or value is invalid.
        public static let invalidDate = POFailureCode(rawValue: "request.validation.invalid-date")

        /// The description provided is invalid.
        public static let invalidDescription = POFailureCode(rawValue: "request.validation.invalid-description")

        /// The specified detail category is invalid.
        public static let invalidDetailCategory = POFailureCode(rawValue: "request.validation.invalid-detail-category")

        /// The detail condition is invalid.
        public static let invalidDetailCondition = POFailureCode(
            rawValue: "request.validation.invalid-detail-condition"
        )

        /// The specified duration value is invalid.
        public static let invalidDuration = POFailureCode(rawValue: "request.validation.invalid-duration")

        /// The provided email address is invalid.
        public static let invalidEmail = POFailureCode(rawValue: "request.validation.invalid-email")

        /// The exemption reason is invalid.
        public static let invalidExemptionReason = POFailureCode(
            rawValue: "request.validation.invalid-exemption-reason"
        )

        /// The external fraud tool data is invalid.
        public static let invalidExternalFraudTools = POFailureCode(
            rawValue: "request.validation.invalid-external-fraud-tools"
        )

        /// The provided gateway data is invalid.
        public static let invalidGatewayData = POFailureCode(rawValue: "request.validation.invalid-gateway-data")

        /// The specified ID is invalid.
        public static let invalidId = POFailureCode(rawValue: "request.validation.invalid-id")

        /// The legal document provided is invalid.
        public static let invalidLegalDocument = POFailureCode(rawValue: "request.validation.invalid-legal-document")

        /// The metadata format or value is invalid.
        public static let invalidMetadata = POFailureCode(rawValue: "request.validation.invalid-metadata")

        /// The name provided is invalid.
        public static let invalidName = POFailureCode(rawValue: "request.validation.invalid-name")

        /// The specified payment type is invalid.
        public static let invalidPaymentType = POFailureCode(rawValue: "request.validation.invalid-payment-type")

        /// The percentage value is invalid.
        public static let invalidPercent = POFailureCode(rawValue: "request.validation.invalid-percent")

        /// The phone number format or value is invalid.
        public static let invalidPhoneNumber = POFailureCode(rawValue: "request.validation.invalid-phone-number")

        /// The quantity value is invalid.
        public static let invalidQuantity = POFailureCode(rawValue: "request.validation.invalid-quantity")

        /// The specified relationship is invalid.
        public static let invalidRelationship = POFailureCode(rawValue: "request.validation.invalid-relationship")

        /// The relay store name is invalid.
        public static let invalidRelayStoreName = POFailureCode(rawValue: "request.validation.invalid-relay-store-name")

        /// The specified role is invalid.
        public static let invalidRole = POFailureCode(rawValue: "request.validation.invalid-role")

        /// The provided settings are invalid.
        public static let invalidSettings = POFailureCode(rawValue: "request.validation.invalid-settings")

        /// The specified sex value is invalid.
        public static let invalidSex = POFailureCode(rawValue: "request.validation.invalid-sex")

        /// The shipping delay value is invalid.
        public static let invalidShippingDelay = POFailureCode(rawValue: "request.validation.invalid-shipping-delay")

        /// The specified shipping method is invalid.
        public static let invalidShippingMethod = POFailureCode(rawValue: "request.validation.invalid-shipping-method")

        /// The sub-account information is invalid.
        public static let invalidSubAccount = POFailureCode(rawValue: "request.validation.invalid-subaccount")

        /// The tax amount is invalid.
        public static let invalidTaxAmount = POFailureCode(rawValue: "request.validation.invalid-tax-amount")

        /// The tax rate specified is invalid.
        public static let invalidTaxRate = POFailureCode(rawValue: "request.validation.invalid-tax-rate")

        /// The provided type is invalid.
        public static let invalidType = POFailureCode(rawValue: "request.validation.invalid-type")

        /// The provided URL format is invalid.
        public static let invalidUrl = POFailureCode(rawValue: "request.validation.invalid-url")

        /// The specified user is invalid.
        public static let invalidUser = POFailureCode(rawValue: "request.validation.invalid-user")

        /// The currency field is missing.
        public static let missingCurrency = POFailureCode(rawValue: "request.validation.missing-currency")

        /// The description field is missing.
        public static let missingDescription = POFailureCode(rawValue: "request.validation.missing-description")

        /// The email field is missing.
        public static let missingEmail = POFailureCode(rawValue: "request.validation.missing-email")

        /// The invoice field is missing.
        public static let missingInvoice = POFailureCode(rawValue: "request.validation.missing-invoice")

        /// The name field is missing.
        public static let missingName = POFailureCode(rawValue: "request.validation.missing-name")

        /// The payment source is missing.
        public static let missingSource = POFailureCode(rawValue: "request.validation.missing-source")

        /// The type field is missing.
        public static let missingType = POFailureCode(rawValue: "request.validation.missing-type")
    }

    public enum Request {

        /// The requested route was not found.
        public static let routeNotFound = POFailureCode(rawValue: "request.route-not-found")

        /// The request is malformed (e.g., incorrect syntax). This usually indicates an issue with the SDK's implementation.
        public static let badFormat = POFailureCode(rawValue: "request.bad-format")

        /// The card used as a source has already been used elsewhere (e.g., for tokenization or payment capture)
        /// and cannot be used again. To reuse a card, create a customer token with the card as the source.
        public static let cardAlreadyUsed = POFailureCode(rawValue: "request.source.card-already-used")

        /// The provided card details are invalid (e.g., incorrect number, expiration date, or CVC).
        public static let invalidCard = POFailureCode(rawValue: "request.card.invalid")

        /// Requested resource details could not be expanded.
        public static let invalidExpand = POFailureCode(rawValue: "request.expand.invalid")

        /// The specified filter is not supported.
        public static let invalidFilter = POFailureCode(rawValue: "request.filter.invalid")

        /// The request has been accepted but is still being processed.
        public static let stillProcessing = POFailureCode(rawValue: "request.still-processing")

        /// The user has sent too many requests in a short period.
        public static let tooMuch = POFailureCode(rawValue: "request.too-much")

        /// The payment gateway is currently unavailable.
        public static let gatewayNotAvailable = POFailureCode(rawValue: "request.gateway.not-available")

        /// The requested operation is not supported by the gateway.
        public static let gatewayOperationNotSupported = POFailureCode(
            rawValue: "request.gateway.operation-not-supported"
        )

        /// The pagination parameters in the request are invalid.
        public static let invalidPagination = POFailureCode(rawValue: "request.pagination.invalid")

        /// The provided payment source is invalid.
        public static let invalidSource = POFailureCode(rawValue: "request.source.invalid")

        /// The required gateway configuration is missing.
        public static let missingGatewayConfiguration = POFailureCode(
            rawValue: "request.configuration.missing-gateway-configuration"
        )

        /// The request rate limit has been exceeded.
        public static let rateExceeded = POFailureCode(rawValue: "request.rate.exceeded")

        /// The transaction has been blocked by ProcessOut for compliance reasons.
        public static let transactionBlocked = POFailureCode(rawValue: "request.transaction-blocked")
    }

    public enum Customer {

        /// Cancellation error.
        public static let cancelled = POFailureCode(rawValue: "customer.cancelled")
    }

    public enum Gateway {

        /// Payment validation failed at the gateway.
        public static let validation = POFailureCode(rawValue: "gateway.validation-error")

        /// Customer-provided data is invalid.
        public static let invalidCustomerInput = POFailureCode(rawValue: "gateway.invalid-customer-input")

        /// Payment state is invalid for the requested action.
        public static let invalidState = POFailureCode(rawValue: "gateway.invalid-state")

        /// Required customer input is missing.
        public static let missingCustomerInput = POFailureCode(rawValue: "gateway.missing-customer-input")

        /// The gateway that attempted to process the payment returned a generic decline.
        /// This can be caused by validation errors, fraud prevention tools, or other specific errors.
        public static let declined = POFailureCode(rawValue: "gateway.declined")

        /// The payment request to the gateway timed out.
        public static let timeout = POFailureCode(rawValue: "gateway.timeout")

        /// The gateway encountered an internal error.
        public static let `internal` = POFailureCode(rawValue: "gateway.internal-error")

        /// Gateway encountered an unknown error.
        public static let unknown = POFailureCode(rawValue: "gateway.unknown-error")
    }

    public enum Resource {

        /// The API key was not found.
        public static let apiKeyNotFound = POFailureCode(rawValue: "resource.api-key.not-found")

        /// The specified card was not found.
        public static let cardNotFound = POFailureCode(rawValue: "resource.card.not-found")

        /// The country was not found.
        public static let countryNotFound = POFailureCode(rawValue: "resource.country.not-found")

        /// The specified currency was not found.
        public static let currencyNotFound = POFailureCode(rawValue: "resource.currency.not-found")

        /// The requested customer was not found.
        public static let customerNotFound = POFailureCode(rawValue: "resource.customer.not-found")

        /// The requested gateway was not found.
        public static let gatewayNotFound = POFailureCode(rawValue: "resource.gateway.not-found")

        /// The specified gateway configuration was not found.
        public static let gatewayConfigurationNotFound = POFailureCode(
            rawValue: "resource.gateway-configuration.not-found"
        )

        /// The requested resource was not found.
        public static let notFound = POFailureCode(rawValue: "resource.not-found")

        /// The invoice was not found.
        public static let invoiceNotFound = POFailureCode(rawValue: "resource.invoice.not-found")

        /// The requested project was not found.
        public static let projectNotFound = POFailureCode(rawValue: "resource.project.not-found")

        /// The requested token was not found.
        public static let tokenNotFound = POFailureCode(rawValue: "resource.token.not-found")
    }

    public enum Mobile {

        /// Some error happend on SDK's side while processing request.
        public static let generic = POFailureCode(rawValue: "processout-mobile.generic.error")

        /// No network connection.
        public static let networkUnreachable = POFailureCode(rawValue: "processout-mobile.network-unreachable")

        /// Timeout error.
        public static let timeout = POFailureCode(rawValue: "processout-mobile.timeout")

        /// Cancellation error.
        public static let cancelled = POFailureCode(rawValue: "processout-mobile.cancelled")

        /// Internal error.
        public static let `internal` = POFailureCode(rawValue: "processout-mobile.internal")
    }

    public enum Generic {

        /// The payment was declined, but no further details were provided.
        public static let paymentDeclined = POFailureCode(rawValue: "payment.declined")

        /// The transaction was blocked due to routing rules.
        public static let routingRulesTransactionBlocked = POFailureCode(rawValue: "routing-rules.transaction-blocked")

        /// This operation is not supported in the sandbox environment.
        public static let sandboxNotSupported = POFailureCode(rawValue: "sandbox.not-supported")

        /// Gateway method is not supported.
        public static let serviceNotSupported = POFailureCode(rawValue: "service.not-supported")
    }
}

// swiftlint:enable inclusive_language file_length
