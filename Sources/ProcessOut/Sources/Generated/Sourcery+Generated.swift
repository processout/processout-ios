// Generated using Sourcery 1.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

@available(iOS 13.0, *)
extension POCardsRepositoryType {

    @MainActor
    public func tokenize(
        request: POCardTokenizationRequest
    ) async throws -> POCard {
        try await withUnsafeThrowingContinuation { continuation in
            tokenize(request: request, completion: continuation.resume)
        }
    }

    @MainActor
    public func updateCvc(
        cardId: String, newCvc: String
    ) async throws -> POCard {
        try await withUnsafeThrowingContinuation { continuation in
            updateCvc(cardId: cardId, newCvc: newCvc, completion: continuation.resume)
        }
    }

    @MainActor
    public func tokenize(
        request: POApplePayCardTokenizationRequest
    ) async throws -> POCard {
        try await withUnsafeThrowingContinuation { continuation in
            tokenize(request: request, completion: continuation.resume)
        }
    }
}

@available(iOS 13.0, *)
extension POCustomerTokensRepositoryType {

    @MainActor
    public func assignCustomerToken(
        request: POCustomerTokensRequest
    ) async throws -> POCustomerAction? {
        try await withUnsafeThrowingContinuation { continuation in
            assignCustomerToken(request: request, completion: continuation.resume)
        }
    }
}

@available(iOS 13.0, *)
extension POGatewayConfigurationsRepositoryType {

    @MainActor
    public func all(
        request: POAllGatewayConfigurationsRequest
    ) async throws -> POAllGatewayConfigurationsResponse {
        try await withUnsafeThrowingContinuation { continuation in
            all(request: request, completion: continuation.resume)
        }
    }

    @MainActor
    public func find(
        id: String
    ) async throws -> POGatewayConfiguration {
        try await withUnsafeThrowingContinuation { continuation in
            find(id: id, completion: continuation.resume)
        }
    }

    @MainActor
    public func all() async throws -> POAllGatewayConfigurationsResponse {
        try await withUnsafeThrowingContinuation { continuation in
            all(completion: continuation.resume)
        }
    }
}

@available(iOS 13.0, *)
extension POInvoicesRepositoryType {

    @MainActor
    public func initiatePayment(
        request: PONativeAlternativePaymentMethodRequest
    ) async throws -> PONativeAlternativePaymentMethodResponse {
        try await withUnsafeThrowingContinuation { continuation in
            initiatePayment(request: request, completion: continuation.resume)
        }
    }

    @MainActor
    public func authorizeInvoice(
        request: POInvoiceAuthorizationRequest
    ) async throws -> POCustomerAction? {
        try await withUnsafeThrowingContinuation { continuation in
            authorizeInvoice(request: request, completion: continuation.resume)
        }
    }

    @MainActor
    @_spi(PO)
    public func createInvoice(
        request: POInvoiceCreationRequest
    ) async throws -> POInvoice {
        try await withUnsafeThrowingContinuation { continuation in
            createInvoice(request: request, completion: continuation.resume)
        }
    }
}

@available(iOS 13.0, *)
extension PORepositoryType {
}
