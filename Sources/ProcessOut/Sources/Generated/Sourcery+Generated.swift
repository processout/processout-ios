// Generated using Sourcery 1.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

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
}
