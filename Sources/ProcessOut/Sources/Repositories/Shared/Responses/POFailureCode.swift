//
//  POFailureCode.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 05.02.2025.
//

// swiftlint:disable inclusive_language file_length

/// Failure code description.
public struct POFailureCode: Sendable, Equatable {

    public struct Namespace: Sendable, Equatable {

        public let rawValue: String
    }

    public let rawValue: String, namespace: Namespace?

    init(rawValue: String) {
        self.rawValue = rawValue
        self.namespace = Namespace.namespace(for: rawValue)
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
        public static let cardExceededLimits = POFailureCode(rawValue: "card.exceeded-limits")

        /// The card CVC check failed
        public static let cardFailedCvc = POFailureCode(rawValue: "card.failed-cvc")

        /// The card holder bank could not process the payment
        public static let cardIssuerDown = POFailureCode(rawValue: "card.issuer-down")

        /// The card holder bank failed to process the transaction.
        public static let cardIssuerFailed = POFailureCode(rawValue: "card.issuer-failed")

        /// The card has no money left in its bank account, the customer should add more funds.
        public static let cardNoMoney = POFailureCode(rawValue: "card.no-money")

        /// The card is not authorized to make the payment.
        public static let cardNotAuthorized = POFailureCode(rawValue: "card.not-authorized")

        /// The card requires a 3DS authentication to be performed, for example in the scope of 3DS2/SCA.
        public static let cardNeedsAuthentication = POFailureCode(rawValue: "card.needs-authentication")

        /// Similarly to payment.declined, the card payment was declined with no further information.
        public static let cardDeclined = POFailureCode(rawValue: "card.declined")

        /// Do Not Honor is the default error code sent by bank, without any additional information.
        public static let cardDoNotHonor = POFailureCode(rawValue: "card.do-not-honor")

        /// No action was done by the payment provider, and should be retried.
        public static let cardNoActionTaken = POFailureCode(rawValue: "card.no-action-taken")

        /// The payment should be retried.
        public static let cardPleaseRetry = POFailureCode(rawValue: "card.please-retry")

        /// The transaction represented a security threat during its processing and was declined.
        public static let cardSecurityViolation = POFailureCode(rawValue: "card.security-violation")

        /// The acquirer used by the payment processor failed to process the transaction.
        public static let cardAcquirerFailed = POFailureCode(rawValue: "card.acquirer-failed")

        /// The processing failed at the acquirer or card holder bank level.
        public static let cardProcessingError = POFailureCode(rawValue: "card.processing-error")

        /// The card maximum payment attempts were reached, the customer should contact its bank.
        public static let cardMaximumAttempts = POFailureCode(rawValue: "card.maximum-attempts")

        /// The card holder bank declined the payment, and should be contacted by your customer.
        public static let cardContactBank = POFailureCode(rawValue: "card.contact-bank")

        /// The card withdrawal limit was reached, the customer should contact its bank.
        public static let cardExceededWithdrawalLimit = POFailureCode(rawValue: "card.exceeded-withdrawal-limit")

        /// The card activity limit was reached, the customer should contact its bank.
        public static let cardExceededActivityLimits = POFailureCode(rawValue: "card.exceeded-activity-limits")

        /// The transaction had high chances of being a duplicate, and was declined.
        public static let cardDuplicate = POFailureCode(rawValue: "card.duplicate")

        /// The payment provider could not find the card issuer bank.
        public static let cardIssuerNotFound = POFailureCode(rawValue: "card.issuer-not-found")

        /// The payment provider failed to contact the card network to process the transaction.
        public static let cardNetworkFailed = POFailureCode(rawValue: "card.network-failed")

        /// The card is not supported by the payment provider.
        public static let cardNotSupported = POFailureCode(rawValue: "card.not-supported")

        /// The currency is not supported by this card.
        public static let cardCurrencyUnsupported = POFailureCode(rawValue: "card.currency-unsupported")

        /// The card type was not supported by the payment provider.
        public static let cardTypeNotSupported = POFailureCode(rawValue: "card.type-not-supported")

        /// The card was not activated yet by the card holder or its bank.
        public static let cardNotActivated = POFailureCode(rawValue: "card.not-activated")

        /// The card was expired.
        public static let cardExpired = POFailureCode(rawValue: "card.expired")

        /// The card was invalid (invalid number/expiration date/CVC).
        public static let cardInvalid = POFailureCode(rawValue: "card.invalid")

        /// The card has an invalid number.
        public static let cardInvalidNumber = POFailureCode(rawValue: "card.invalid-number")

        /// The card PIN was invalid. This error code does not apply for online payments.
        public static let cardInvalidPin = POFailureCode(rawValue: "card.invalid-pin")

        /// The name on the card was invalid (potential AVS failure).
        public static let cardInvalidName = POFailureCode(rawValue: "card.invalid-name")

        /// The card expiration date was invalid.
        public static let cardInvalidExpiryDate = POFailureCode(rawValue: "card.invalid-expiry-date")

        /// The card expiration month was invalid.
        public static let cardInvalidExpiryMonth = POFailureCode(rawValue: "card.invalid-expiry-month")

        /// The card expiration year was invalid.
        public static let cardInvalidExpiryYear = POFailureCode(rawValue: "card.invalid-expiry-year")

        /// The card holder ZIP code was invalid (potential AVS failure).
        public static let cardInvalidZip = POFailureCode(rawValue: "card.invalid-zip")

        /// The card holder address was invalid (potential AVS failure).
        public static let cardInvalidAddress = POFailureCode(rawValue: "card.invalid-address")

        /// The card CVC was missing, but needed to process the payment.
        public static let cardMissingCvc = POFailureCode(rawValue: "card.missing-cvc")

        /// Invalid CVC.
        public static let cardInvalidCvc = POFailureCode(rawValue: "card.invalid-cvc")

        /// The card expiry date was missing, but needed to process the payment.
        public static let cardMissingExpiry = POFailureCode(rawValue: "card.missing-expiry")

        /// The card number was missing.
        public static let cardMissingNumber = POFailureCode(rawValue: "card.missing-number")

        /// The card 3DS verification process was missing but needed to process the payment.
        public static let cardMissing3DS = POFailureCode(rawValue: "card.missing-3ds")

        /// The card AVS check failed.
        public static let cardFailedAvs = POFailureCode(rawValue: "card.failed-avs")

        /// The card AVS check failed on the postal code.
        public static let cardFailedAvsPostal = POFailureCode(rawValue: "card.failed-avs-postal")

        /// The card does not support 3DS authentication (but a 3DS authentication was requested).
        public static let cardUnsupported3DS = POFailureCode(rawValue: "card.unsupported-3ds")

        /// The transaction was blocked from authorization due to the 3DS transaction status being in
        /// the authenticating phase.
        public static let cardPending3DS = POFailureCode(rawValue: "card.pending-3ds")

        /// The card 3DS check failed.
        public static let cardFailed3DS = POFailureCode(rawValue: "card.failed-3ds")

        /// The card 3DS check expired and needs to be retried.
        public static let cardExpired3DS = POFailureCode(rawValue: "card.expired-3ds")

        /// The card AVS check failed on the address.
        public static let cardFailedAvsAddress = POFailureCode(rawValue: "card.failed-avs-address")

        /// Both the card CVC and AVS checks failed.
        public static let cardFailedCvcAndAvs = POFailureCode(rawValue: "card.failed-cvc-and-avs")

        /// The track data of the card was invalid (expiration date or CVC).
        public static let cardBadTrackData = POFailureCode(rawValue: "card.bad-track-data")

        /// The card was not yet registered and can therefore not process payments.
        public static let cardNotRegistered = POFailureCode(rawValue: "card.not-registered")

        /// The card was stolen.
        public static let cardStolen = POFailureCode(rawValue: "card.stolen")

        /// The card was lost by its card holder.
        public static let cardLost = POFailureCode(rawValue: "card.lost")

        /// The payment should not be retried.
        public static let cardDontRetry = POFailureCode(rawValue: "card.dont-retry")

        /// The card bank account was invalid, the customer should contact its bank.
        public static let cardInvalidAccount = POFailureCode(rawValue: "card.invalid-account")

        /// The card was revoked.
        public static let cardRevoked = POFailureCode(rawValue: "card.revoked")

        /// All the card holder cards were revoked.
        public static let cardRevokedAll = POFailureCode(rawValue: "card.revoked-all")

        /// The card was a test card and can't be used to process live transactions.
        public static let cardTest = POFailureCode(rawValue: "card.test")

        /// The card was blacklisted from the payment provider
        public static let cardBlacklisted = POFailureCode(rawValue: "card.blacklisted")
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

        /// The device channel specified is invalid.
        public static let invalidDeviceChannel = POFailureCode(rawValue: "request.validation.invalid-device-channel")

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

        /// The provided IP address is invalid.
        public static let invalidIpAddress = POFailureCode(rawValue: "request.validation.invalid-ip-address")

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

        /// The provided idempotency key is invalid.
        public static let invalidIdempotency = POFailureCode(rawValue: "request.idempotency-key.invalid")

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

        /// Gateway encountered an unknown error.
        public static let unknown = POFailureCode(rawValue: "gateway.unknown-error")

        /// The gateway encountered an internal error.
        public static let `internal` = POFailureCode(rawValue: "gateway.internal-error")

        /// The payment request to the gateway timed out.
        public static let timeout = POFailureCode(rawValue: "gateway.timeout")
    }

    public enum Mobile {

        /// No network connection.
        public static let networkUnreachable = POFailureCode(rawValue: "processout-mobile.network-unreachable")

        /// Timeout error.
        public static let timeout = POFailureCode(rawValue: "processout-mobile.timeout")

        /// Internal error.
        public static let `internal` = POFailureCode(rawValue: "processout-mobile.internal")
    }

    public enum Resource {

        /// The specified activity was not found.
        public static let activityNotFound = POFailureCode(rawValue: "resource.activity.not-found")

        /// The specified add-on was not found.
        public static let addonNotFound = POFailureCode(rawValue: "resource.addon.not-found")

        /// The requested alert was not found.
        public static let alertNotFound = POFailureCode(rawValue: "resource.alert.not-found")

        /// The API key was not found.
        public static let apiKeyNotFound = POFailureCode(rawValue: "resource.api-key.not-found")

        /// The requested API request was not found.
        public static let apiRequestNotFound = POFailureCode(rawValue: "resource.api-request.not-found")

        /// The specified API version was not found.
        public static let apiVersionNotFound = POFailureCode(rawValue: "resource.api-version.not-found")

        /// The Apple Pay configuration was not found.
        public static let applepayConfigurationNotFound = POFailureCode(
            rawValue: "resource.applepay-configuration.not-found"
        )

        /// The requested board was not found.
        public static let boardNotFound = POFailureCode(rawValue: "resource.board.not-found")

        /// The specified card was not found.
        public static let cardNotFound = POFailureCode(rawValue: "resource.card.not-found")

        /// The requested chart was not found.
        public static let chartNotFound = POFailureCode(rawValue: "resource.chart.not-found")

        /// The specified collaborator was not found.
        public static let collaboratorNotFound = POFailureCode(rawValue: "resource.collaborator.not-found")

        /// The country was not found.
        public static let countryNotFound = POFailureCode(rawValue: "resource.country.not-found")

        /// The coupon was not found.
        public static let couponNotFound = POFailureCode(rawValue: "resource.coupon.not-found")

        /// The specified currency was not found.
        public static let currencyNotFound = POFailureCode(rawValue: "resource.currency.not-found")

        /// The requested customer was not found.
        public static let customerNotFound = POFailureCode(rawValue: "resource.customer.not-found")

        /// The discount was not found.
        public static let discountNotFound = POFailureCode(rawValue: "resource.discount.not-found")

        /// The specified event was not found.
        public static let eventNotFound = POFailureCode(rawValue: "resource.event.not-found")

        /// The requested export was not found.
        public static let exportNotFound = POFailureCode(rawValue: "resource.export.not-found")

        /// The fraud service configuration was not found.
        public static let fraudServiceConfigurationNotFound = POFailureCode(
            rawValue: "resource.fraud-service-configuration.not-found"
        )

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

        /// The requested payout was not found.
        public static let payoutNotFound = POFailureCode(rawValue: "resource.payout.not-found")

        /// The specified permission group was not found.
        public static let permissionGroupNotFound = POFailureCode(rawValue: "resource.permission-group.not-found")

        /// The requested plan was not found.
        public static let planNotFound = POFailureCode(rawValue: "resource.plan.not-found")

        /// The product was not found.
        public static let productNotFound = POFailureCode(rawValue: "resource.product.not-found")

        /// The requested project was not found.
        public static let projectNotFound = POFailureCode(rawValue: "resource.project.not-found")

        /// The refund was not found.
        public static let refundNotFound = POFailureCode(rawValue: "resource.refund.not-found")

        /// The specified subscription was not found.
        public static let subscriptionNotFound = POFailureCode(rawValue: "resource.subscription.not-found")

        /// The requested token was not found.
        public static let tokenNotFound = POFailureCode(rawValue: "resource.token.not-found")

        /// The tokenization request was not found.
        public static let tokenizationRequestNotFound = POFailureCode(
            rawValue: "resource.tokenization-request.not-found"
        )

        /// The transaction was not found.
        public static let transactionNotFound = POFailureCode(rawValue: "resource.transaction.not-found")

        /// The specified user was not found.
        public static let userNotFound = POFailureCode(rawValue: "resource.user.not-found")

        /// The webhook endpoint was not found.
        public static let webhookEndpointNotFound = POFailureCode(rawValue: "resource.webhook-endpoint.not-found")

        /// Indicates that resource is not linked.
        public static let resourceNotLinked = POFailureCode(rawValue: "resource.not-linked")
    }

    public enum Generic {

        /// The payment was declined, but no further details were provided.
        public static let paymentDeclined = POFailureCode(rawValue: "payment.declined")

        /// The transaction was blocked due to routing rules.
        public static let routingRulesTransactionBlocked = POFailureCode(rawValue: "routing-rules.transaction-blocked")

        /// This operation is not supported in the sandbox environment.
        public static let sandboxNotSupported = POFailureCode(rawValue: "sandbox.not-supported")

        /// This service is not supported.
        public static let serviceNotSupported = POFailureCode(rawValue: "service.not-supported")
    }
}

extension POFailureCode.Namespace {

    /// Authentication errors.
    public static let authentication = POFailureCode.Namespace(rawValue: "request.authentication")

    /// Card errors.
    public static let card = POFailureCode.Namespace(rawValue: "card")

    /// Request validation errors.
    public static let requestValidation = POFailureCode.Namespace(rawValue: "request.validation")

    /// Request errors.
    public static let request = POFailureCode.Namespace(rawValue: "request")

    /// Customer errors.
    public static let customer = POFailureCode.Namespace(rawValue: "customer")

    /// Gateway errors.
    public static let gateway = POFailureCode.Namespace(rawValue: "gateway")

    /// Mobile errors.
    public static let mobile = POFailureCode.Namespace(rawValue: "processout-mobile")

    /// Resource errors.
    public static let resource = POFailureCode.Namespace(rawValue: "resource")
}

extension POFailureCode.Namespace {

    static func namespace(for rawErrorCode: String) -> Self? {
        let knownNamespaces: [Self] = [
            .authentication, .card, .requestValidation, .request, .customer, .gateway, .mobile, .resource
        ]
        for namespace in knownNamespaces where rawErrorCode.hasPrefix(namespace.rawValue) {
            return namespace
        }
        return nil
    }
}

// swiftlint:enable inclusive_language file_length
