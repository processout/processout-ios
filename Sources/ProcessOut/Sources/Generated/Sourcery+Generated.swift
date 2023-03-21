// Generated using Sourcery 1.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

@available(iOS 13.0, *)
extension CustomerTokensRepositoryType {

    @MainActor
    public func assignCustomerToken(
        request: POAssignCustomerTokenRequest
    ) async throws -> ThreeDSCustomerAction? {
        return try await withUnsafeThrowingContinuation { continuation in
            assignCustomerToken(request: request, completion: continuation.resume)
        }
    }

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
extension InvoicesRepositoryType {

    @MainActor
    public func nativeAlternativePaymentMethodTransactionDetails(
        request: PONativeAlternativePaymentMethodTransactionDetailsRequest
    ) async throws -> PONativeAlternativePaymentMethodTransactionDetails {
        return try await withUnsafeThrowingContinuation { continuation in
            nativeAlternativePaymentMethodTransactionDetails(request: request, completion: continuation.resume)
        }
    }

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
    ) async throws -> ThreeDSCustomerAction? {
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
    public func updateCard(
        request: POCardUpdateRequest
    ) async throws -> POCard {
        return try await withUnsafeThrowingContinuation { continuation in
            updateCard(request: request, completion: continuation.resume)
        }
    }

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
extension POCardsServiceType {

    @MainActor
    public func tokenize(
        request: POCardTokenizationRequest
    ) async throws -> POCard {
        return try await withUnsafeThrowingContinuation { continuation in
            tokenize(request: request, completion: continuation.resume)
        }
    }

    @MainActor
    public func updateCard(
        request: POCardUpdateRequest
    ) async throws -> POCard {
        return try await withUnsafeThrowingContinuation { continuation in
            updateCard(request: request, completion: continuation.resume)
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
        request: POAssignCustomerTokenRequest, threeDSService: PO3DSServiceType
    ) async throws -> Void {
        return try await withUnsafeThrowingContinuation { continuation in
            assignCustomerToken(request: request, threeDSService: threeDSService, completion: continuation.resume)
        }
    }

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
    public func nativeAlternativePaymentMethodTransactionDetails(
        request: PONativeAlternativePaymentMethodTransactionDetailsRequest
    ) async throws -> PONativeAlternativePaymentMethodTransactionDetails {
        return try await withUnsafeThrowingContinuation { continuation in
            nativeAlternativePaymentMethodTransactionDetails(request: request, completion: continuation.resume)
        }
    }

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
        request: POInvoiceAuthorizationRequest, threeDSService: PO3DSServiceType
    ) async throws -> Void {
        return try await withUnsafeThrowingContinuation { continuation in
            authorizeInvoice(request: request, threeDSService: threeDSService, completion: continuation.resume)
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
