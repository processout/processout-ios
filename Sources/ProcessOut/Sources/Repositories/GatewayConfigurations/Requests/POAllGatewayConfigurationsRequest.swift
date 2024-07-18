//
//  POAllGatewayConfigurationsRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.10.2022.
//

public struct POAllGatewayConfigurationsRequest: Sendable {

    public enum Filter: String, Sendable {

        /// Gateways that allow payments using alternative payment methods that allow tokenization.
        case alternativePaymentMethodsWithTokenization // swiftlint:disable:this identifier_name
            = "alternative-payment-methods-with-tokenization"

        /// Gateways that allow payments using alternative payment methods.
        case alternativePaymentMethods = "alternative-payment-methods"

        /// Gateways that allow card-payments only.
        case cardPayments = "card-payments"

        /// Gateways that allow payments using native alternative payment methods.
        case nativeAlternativePaymentMethods = "native-alternative-payment-methods"
    }

    /// Filter to apply to request.
    public let filter: Filter?

    /// Pagination options.
    public let paginationOptions: POPaginationOptions?

    /// Flag indicating whether disabled configurations should be returned in response.
    public let includeDisabled: Bool

    /// Creates request with given parameters.
    public init(
        filter: Filter? = nil, paginationOptions: POPaginationOptions? = nil, includeDisabled: Bool = false
    ) {
        self.filter = filter
        self.paginationOptions = paginationOptions
        self.includeDisabled = includeDisabled
    }
}
