// Generated using Sourcery 2.0.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

@available(iOS 13.0, *)
extension CardsRepository {

    /// Tokenize a card.
    @MainActor
    public func tokenize(
        request: POCardTokenizationRequest
    ) async throws -> POCard {
        return try await withUnsafeThrowingContinuation { continuation in
            tokenize(request: request, completion: continuation.resume)
        }
    }

    /// Updates card information.
    @MainActor
    public func updateCard(
        request: POCardUpdateRequest
    ) async throws -> POCard {
        return try await withUnsafeThrowingContinuation { continuation in
            updateCard(request: request, completion: continuation.resume)
        }
    }

    /// Tokenize a card via ApplePay.
    @MainActor
    public func tokenize(
        request: ApplePayCardTokenizationRequest
    ) async throws -> POCard {
        return try await withUnsafeThrowingContinuation { continuation in
            tokenize(request: request, completion: continuation.resume)
        }
    }
}

@available(iOS 13.0, *)
extension CustomerTokensRepository {

    /// Assigns a token to a customer.
    @MainActor
    public func assignCustomerToken(
        request: POAssignCustomerTokenRequest
    ) async throws -> AssignCustomerTokenResponse {
        return try await withUnsafeThrowingContinuation { continuation in
            assignCustomerToken(request: request, completion: continuation.resume)
        }
    }

    /// Create customer token.
    @MainActor
    public func createCustomerToken(
        request: POCreateCustomerTokenRequest
    ) async throws -> POCustomerToken {
        return try await withUnsafeThrowingContinuation { continuation in
            createCustomerToken(request: request, completion: continuation.resume)
        }
    }
}

@available(iOS 13.0, *)
extension InvoicesRepository {

    /// Requests information needed to continue existing payment or start new one.
    @MainActor
    public func nativeAlternativePaymentMethodTransactionDetails(
        request: PONativeAlternativePaymentMethodTransactionDetailsRequest
    ) async throws -> PONativeAlternativePaymentMethodTransactionDetails {
        return try await withUnsafeThrowingContinuation { continuation in
            nativeAlternativePaymentMethodTransactionDetails(request: request, completion: continuation.resume)
        }
    }

    /// Initiates native alternative payment with a given request.
    /// 
    /// Some Native APMs require further information to be collected back from the customer. You can inspect
    /// `nativeApm` in response object to understand if additional data is required.
    @MainActor
    public func initiatePayment(
        request: PONativeAlternativePaymentMethodRequest
    ) async throws -> PONativeAlternativePaymentMethodResponse {
        return try await withUnsafeThrowingContinuation { continuation in
            initiatePayment(request: request, completion: continuation.resume)
        }
    }

    /// Performs invoice authorization with given request.
    @MainActor
    public func authorizeInvoice(
        request: POInvoiceAuthorizationRequest
    ) async throws -> ThreeDSCustomerAction? {
        return try await withUnsafeThrowingContinuation { continuation in
            authorizeInvoice(request: request, completion: continuation.resume)
        }
    }

    /// Creates invoice with given parameters.
    @MainActor
    public func createInvoice(
        request: POInvoiceCreationRequest
    ) async throws -> POInvoice {
        return try await withUnsafeThrowingContinuation { continuation in
            createInvoice(request: request, completion: continuation.resume)
        }
    }
}

@available(iOS 13.0, *)
extension LogsRepository {
}

@available(iOS 13.0, *)
extension POCardsService {

    /// Tokenizes a card. You can use the card for a single payment by creating a card token with it. If you want
    /// to use the card for multiple payments then you can use the card token to create a reusable customer token.
    /// Note that once you have used the card token either for a payment or to create a customer token, the card
    /// token becomes invalid and you cannot use it for any further actions.
    @MainActor
    public func tokenize(
        request: POCardTokenizationRequest
    ) async throws -> POCard {
        return try await withUnsafeThrowingContinuation { continuation in
            tokenize(request: request, completion: continuation.resume)
        }
    }

    /// Updates card information.
    @MainActor
    public func updateCard(
        request: POCardUpdateRequest
    ) async throws -> POCard {
        return try await withUnsafeThrowingContinuation { continuation in
            updateCard(request: request, completion: continuation.resume)
        }
    }

    /// Tokenize a card via ApplePay. You can use the card for a single payment by creating a card token with it.
    @MainActor
    public func tokenize(
        request: POApplePayCardTokenizationRequest
    ) async throws -> POCard {
        return try await withUnsafeThrowingContinuation { continuation in
            tokenize(request: request, completion: continuation.resume)
        }
    }
}

@available(iOS 13.0, *)
extension POCustomerTokensService {

    /// Assigns new source to existing customer token and optionaly verifies it.
    @MainActor
    public func assignCustomerToken(
        request: POAssignCustomerTokenRequest, threeDSService: PO3DSService
    ) async throws -> POCustomerToken {
        return try await withUnsafeThrowingContinuation { continuation in
            assignCustomerToken(request: request, threeDSService: threeDSService, completion: continuation.resume)
        }
    }

    /// Creates customer token using given request.
    @MainActor
    @_spi(PO)
    public func createCustomerToken(
        request: POCreateCustomerTokenRequest
    ) async throws -> POCustomerToken {
        return try await withUnsafeThrowingContinuation { continuation in
            createCustomerToken(request: request, completion: continuation.resume)
        }
    }
}

@available(iOS 13.0, *)
extension POGatewayConfigurationsRepository {

    /// Returns available gateway configurations.
    @MainActor
    public func all(
        request: POAllGatewayConfigurationsRequest
    ) async throws -> POAllGatewayConfigurationsResponse {
        return try await withUnsafeThrowingContinuation { continuation in
            all(request: request, completion: continuation.resume)
        }
    }

    /// Searches configuration with given request.
    @MainActor
    public func find(
        request: POFindGatewayConfigurationRequest
    ) async throws -> POGatewayConfiguration {
        return try await withUnsafeThrowingContinuation { continuation in
            find(request: request, completion: continuation.resume)
        }
    }

    /// Returns available gateway configurations.
    @MainActor
    public func all() async throws -> POAllGatewayConfigurationsResponse {
        return try await withUnsafeThrowingContinuation { continuation in
            all(completion: continuation.resume)
        }
    }
}

@available(iOS 13.0, *)
extension POInvoicesService {

    /// Requests information needed to continue existing payment or start new one.
    @MainActor
    public func nativeAlternativePaymentMethodTransactionDetails(
        request: PONativeAlternativePaymentMethodTransactionDetailsRequest
    ) async throws -> PONativeAlternativePaymentMethodTransactionDetails {
        return try await withUnsafeThrowingContinuation { continuation in
            nativeAlternativePaymentMethodTransactionDetails(request: request, completion: continuation.resume)
        }
    }

    /// Initiates native alternative payment with a given request.
    /// 
    /// Some Native APMs require further information to be collected back from the customer. You can inspect
    /// `nativeApm` in response object to understand if additional data is required.
    @MainActor
    public func initiatePayment(
        request: PONativeAlternativePaymentMethodRequest
    ) async throws -> PONativeAlternativePaymentMethodResponse {
        return try await withUnsafeThrowingContinuation { continuation in
            initiatePayment(request: request, completion: continuation.resume)
        }
    }

    /// Performs invoice authorization with given request.
    @MainActor
    public func authorizeInvoice(
        request: POInvoiceAuthorizationRequest, threeDSService: PO3DSService
    ) async throws -> Void {
        return try await withUnsafeThrowingContinuation { continuation in
            authorizeInvoice(request: request, threeDSService: threeDSService, completion: continuation.resume)
        }
    }

    /// Creates invoice with given parameters.
    @MainActor
    @_spi(PO)
    public func createInvoice(
        request: POInvoiceCreationRequest
    ) async throws -> POInvoice {
        return try await withUnsafeThrowingContinuation { continuation in
            createInvoice(request: request, completion: continuation.resume)
        }
    }
}

@available(iOS 13.0, *)
extension PORepository {
}

@available(iOS 13.0, *)
extension POService {
}
