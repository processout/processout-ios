//
//  DefaultAlternativePaymentsService.swift
//  ProcessOut
//
//  Created by Simeon Kostadinov on 27/10/2022.
//

import Foundation

final class DefaultAlternativePaymentsService: POAlternativePaymentsService {

    init(
        configuration: @escaping @Sendable () -> AlternativePaymentsServiceConfiguration,
        webSession: WebAuthenticationSession,
        logger: POLogger
    ) {
        self.configuration = configuration
        self.webSession = webSession
        self.logger = logger
    }

    // MARK: - POAlternativePaymentsService

    func tokenize(request: POAlternativePaymentTokenizationRequest) async throws -> POAlternativePaymentResponse {
        try await authenticate(using: url(for: request))
    }

    func authorize(request: POAlternativePaymentAuthorizationRequest) async throws -> POAlternativePaymentResponse {
        try await authenticate(using: url(for: request))
    }

    func url(for request: POAlternativePaymentTokenizationRequest) throws -> URL {
        let pathComponents = [request.customerId, request.tokenId, "redirect", request.gatewayConfigurationId]
        return try url(with: pathComponents, additionalData: request.additionalData)
    }

    func url(for request: POAlternativePaymentAuthorizationRequest) throws -> URL {
        var pathComponents = [request.invoiceId, "redirect", request.gatewayConfigurationId]
        if let tokenId = request.tokenId {
            pathComponents += ["tokenized", tokenId]
        }
        return try url(with: pathComponents, additionalData: request.additionalData)
    }

    func authenticate(using url: URL) async throws -> POAlternativePaymentResponse {
        let returnUrl = try await webSession.authenticate(using: url)
        return try response(from: returnUrl)
    }

    @available(*, deprecated)
    func alternativePaymentMethodUrl(request: POAlternativePaymentMethodRequest) -> URL {
        do {
            if let customerId = request.customerId, let tokenId = request.tokenId {
                let tokenizationRequest = POAlternativePaymentTokenizationRequest(
                    customerId: customerId,
                    tokenId: tokenId,
                    gatewayConfigurationId: request.gatewayConfigurationId,
                    additionalData: request.additionalData
                )
                return try url(for: tokenizationRequest)
            }
            let authorizationRequest = POAlternativePaymentAuthorizationRequest(
                invoiceId: request.invoiceId,
                gatewayConfigurationId: request.gatewayConfigurationId,
                tokenId: request.tokenId,
                additionalData: request.additionalData
            )
            return try url(for: authorizationRequest)
        } catch {
            preconditionFailure("Failed to create APM redirection URL.")
        }
    }

    @available(*, deprecated)
    func alternativePaymentMethodResponse(url: URL) throws -> POAlternativePaymentMethodResponse {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            let message = "Invalid or malformed Alternative Payment Method URL response provided."
            throw POFailure(message: message, code: .generic(.mobile), underlyingError: nil)
        }
        let queryItems = components.queryItems ?? []
        if let errorCode = queryItems.queryItemValue(name: "error_code") {
            throw POFailure(code: createFailureCode(rawValue: errorCode))
        }
        let gatewayToken = queryItems.queryItemValue(name: "token") ?? ""
        if gatewayToken.isEmpty {
            logger.debug("Gateway 'token' is not set in \(url), this may be an error.")
        }
        let tokenId = queryItems.queryItemValue(name: "token_id")
        if let customerId = queryItems.queryItemValue(name: "customer_id"), let tokenId {
            return .init(gatewayToken: gatewayToken, customerId: customerId, tokenId: tokenId, returnType: .createToken)
        }
        return .init(gatewayToken: gatewayToken, customerId: nil, tokenId: tokenId, returnType: .authorization)
    }

    // MARK: - Private

    private let configuration: @Sendable () -> AlternativePaymentsServiceConfiguration
    private let logger: POLogger
    private let webSession: WebAuthenticationSession

    // MARK: - Request

    /// - NOTE: Method prepends project ID to path components automatically.
    private func url(with additionalPathComponents: [String], additionalData: [String: String]?) throws -> URL {
        let configuration = self.configuration()
        guard var components = URLComponents(url: configuration.baseUrl, resolvingAgainstBaseURL: true) else {
            preconditionFailure("Invalid base URL.")
        }
        let pathComponents = [configuration.projectId] + additionalPathComponents
        components.path = "/" + pathComponents.joined(separator: "/")
        components.queryItems = additionalData?.map { data in
            URLQueryItem(name: "additional_data[" + data.key + "]", value: data.value)
        }
        if let url = components.url {
            return url
        }
        throw POFailure(message: "Unable to create redirect URL.", code: .generic(.mobile))
    }

    // MARK: - Response

    private func response(from url: URL) throws -> POAlternativePaymentResponse {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            let message = "Invalid or malformed Alternative Payment Method URL response provided."
            throw POFailure(message: message, code: .generic(.mobile), underlyingError: nil)
        }
        let queryItems = components.queryItems ?? []
        if let errorCode = queryItems.queryItemValue(name: "error_code") {
            throw POFailure(code: createFailureCode(rawValue: errorCode))
        }
        let gatewayToken = queryItems.queryItemValue(name: "token") ?? ""
        if gatewayToken.isEmpty {
            logger.debug("Gateway 'token' is not set in \(url), this may be an error.")
        }
        return .init(gatewayToken: gatewayToken)
    }

    private func createFailureCode(rawValue: String) -> POFailure.Code {
        if let code = POFailure.AuthenticationCode(rawValue: rawValue) {
            return .authentication(code)
        } else if let code = POFailure.NotFoundCode(rawValue: rawValue) {
            return .notFound(code)
        } else if let code = POFailure.ValidationCode(rawValue: rawValue) {
            return .validation(code)
        } else if let code = POFailure.GenericCode(rawValue: rawValue) {
            return .generic(code)
        } else if let code = POFailure.TimeoutCode(rawValue: rawValue) {
            return .timeout(code)
        } else if let code = POFailure.InternalCode(rawValue: rawValue) {
            return .internal(code)
        }
        return .unknown(rawValue: rawValue)
    }
}

private extension Array where Element == URLQueryItem { // swiftlint:disable:this no_extension_access_modifier

    func queryItemValue(name: String) -> String? {
        first { $0.name == name }?.value
    }
}
