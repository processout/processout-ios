// Generated using Sourcery 1.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

@available(iOS 13.0, *)
extension CustomerTokensRepositoryType {

    @MainActor
    public func assignCustomerToken(
        request: POAssignCustomerTokenRequest
    ) async throws -> CustomerAction? {
        return try await withUnsafeThrowingContinuation { continuation in
            assignCustomerToken(request: request, completion: continuation.resume)
        }
    }

    @MainActor
    public func createCustomerToken(
        request: POCustomerTokenCreationRequest
    ) async throws -> POCustomerToken {
        return try await withUnsafeThrowingContinuation { continuation in
            createCustomerToken(request: request, completion: continuation.resume)
        }
    }
}

@available(iOS 13.0, *)
extension InvoicesRepositoryType {

    @MainActor
    public func initiatePayment(
        request: PONativeAlternativePaymentMethodRequest
    ) async throws -> PONativeAlternativePaymentMethodResponse {
        return try await withUnsafeThrowingContinuation { continuation in
            initiatePayment(request: request, completion: continuation.resume)
        }
    }

    @MainActor
    public func authorizeInvoice(
        request: POInvoiceAuthorizationRequest
    ) async throws -> CustomerAction? {
        return try await withUnsafeThrowingContinuation { continuation in
            authorizeInvoice(request: request, completion: continuation.resume)
        }
    }

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
extension POCardsRepositoryType {

    @MainActor
    public func tokenize(
        request: POCardTokenizationRequest
    ) async throws -> POCard {
        return try await withUnsafeThrowingContinuation { continuation in
            tokenize(request: request, completion: continuation.resume)
        }
    }

    @MainActor
    public func updateCvc(
        cardId: String, newCvc: String
    ) async throws -> POCard {
        return try await withUnsafeThrowingContinuation { continuation in
            updateCvc(cardId: cardId, newCvc: newCvc, completion: continuation.resume)
        }
    }

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
extension POCustomerTokensServiceType {

    @MainActor
    public func assignCustomerToken(
        request: POAssignCustomerTokenRequest, customerActionHandlerDelegate: POCustomerActionHandlerDelegate
    ) async throws -> Void {
        return try await withUnsafeThrowingContinuation { continuation in
            assignCustomerToken(request: request, customerActionHandlerDelegate: customerActionHandlerDelegate, completion: continuation.resume)
        }
    }

    @MainActor
    @_spi(PO)
    public func createCustomerToken(
        request: POCustomerTokenCreationRequest
    ) async throws -> POCustomerToken {
        return try await withUnsafeThrowingContinuation { continuation in
            createCustomerToken(request: request, completion: continuation.resume)
        }
    }
}

@available(iOS 13.0, *)
extension POGatewayConfigurationsRepositoryType {

    @MainActor
    public func all(
        request: POAllGatewayConfigurationsRequest
    ) async throws -> POAllGatewayConfigurationsResponse {
        return try await withUnsafeThrowingContinuation { continuation in
            all(request: request, completion: continuation.resume)
        }
    }

    @MainActor
    public func find(
        request: POFindGatewayConfigurationRequest
    ) async throws -> POGatewayConfiguration {
        return try await withUnsafeThrowingContinuation { continuation in
            find(request: request, completion: continuation.resume)
        }
    }

    @MainActor
    public func all() async throws -> POAllGatewayConfigurationsResponse {
        return try await withUnsafeThrowingContinuation { continuation in
            all(completion: continuation.resume)
        }
    }
}

@available(iOS 13.0, *)
extension POInvoicesServiceType {

    @MainActor
    public func initiatePayment(
        request: PONativeAlternativePaymentMethodRequest
    ) async throws -> PONativeAlternativePaymentMethodResponse {
        return try await withUnsafeThrowingContinuation { continuation in
            initiatePayment(request: request, completion: continuation.resume)
        }
    }

    @MainActor
    public func authorizeInvoice(
        request: POInvoiceAuthorizationRequest, customerActionHandlerDelegate: POCustomerActionHandlerDelegate
    ) async throws -> Void {
        return try await withUnsafeThrowingContinuation { continuation in
            authorizeInvoice(request: request, customerActionHandlerDelegate: customerActionHandlerDelegate, completion: continuation.resume)
        }
    }

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
extension PORepositoryType {
}

@available(iOS 13.0, *)
extension POServiceType {
}
