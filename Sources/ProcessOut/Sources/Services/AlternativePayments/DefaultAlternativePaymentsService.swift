//
//  DefaultAlternativePaymentsService.swift
//  ProcessOut
//
//  Created by Simeon Kostadinov on 27/10/2022.
//

import Foundation

final class DefaultAlternativePaymentsService: POAlternativePaymentsService {

    init(
        configuration: POAlternativePaymentsServiceConfiguration,
        webSession: WebAuthenticationSession,
        logger: POLogger
    ) {
        self.configuration = .init(wrappedValue: configuration)
        self.webSession = webSession
        self.logger = logger
    }

    // MARK: - POAlternativePaymentsService

    func tokenize(request: POAlternativePaymentTokenizationRequest) async throws -> POAlternativePaymentResponse {
        let authenticationRequest = POAlternativePaymentAuthenticationRequest(
            url: try url(for: request),
            callback: request.callback,
            prefersEphemeralSession: request.prefersEphemeralSession
        )
        return try await authenticate(request: authenticationRequest)
    }

    func authorize(request: POAlternativePaymentAuthorizationRequest) async throws -> POAlternativePaymentResponse {
        let authenticationRequest = POAlternativePaymentAuthenticationRequest(
            url: try url(for: request),
            callback: request.callback,
            prefersEphemeralSession: request.prefersEphemeralSession
        )
        return try await authenticate(request: authenticationRequest)
    }

    func authenticate(request: POAlternativePaymentAuthenticationRequest) async throws -> POAlternativePaymentResponse {
        do {
            let returnUrl = try await webSession.authenticate(
                using: .init(
                    url: request.url,
                    callback: request.callback,
                    prefersEphemeralSession: request.prefersEphemeralSession
                )
            )
            let response = try response(from: returnUrl)
            logger.debug("Did authenticate alternative payment: \(response.gatewayToken)")
            return response
        } catch {
            logger.debug("Did fail to authenticate alternative payment: \(error)")
            throw error
        }
    }

    func url(for request: POAlternativePaymentTokenizationRequest) throws -> URL {
        let pathComponents = [request.customerId, request.customerTokenId, "redirect", request.gatewayConfigurationId]
        return try url(with: pathComponents, additionalData: request.additionalData)
    }

    func url(for request: POAlternativePaymentAuthorizationRequest) throws -> URL {
        var pathComponents = [request.invoiceId, "redirect", request.gatewayConfigurationId]
        if let tokenId = request.customerTokenId {
            pathComponents += ["tokenized", tokenId]
        }
        return try url(with: pathComponents, additionalData: request.additionalData)
    }

    @available(*, deprecated)
    func alternativePaymentMethodUrl(request: POAlternativePaymentMethodRequest) -> URL {
        do {
            if let customerId = request.customerId, let tokenId = request.tokenId {
                let tokenizationRequest = POAlternativePaymentTokenizationRequest(
                    customerId: customerId,
                    customerTokenId: tokenId,
                    gatewayConfigurationId: request.gatewayConfigurationId,
                    additionalData: request.additionalData
                )
                return try url(for: tokenizationRequest)
            }
            let authorizationRequest = POAlternativePaymentAuthorizationRequest(
                invoiceId: request.invoiceId,
                gatewayConfigurationId: request.gatewayConfigurationId,
                customerTokenId: request.tokenId,
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
            let message = "Invalid or malformed alternative payment method URL response provided."
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

    private let configuration: POUnfairlyLocked<POAlternativePaymentsServiceConfiguration>
    private let logger: POLogger
    private let webSession: WebAuthenticationSession

    // MARK: - Request

    /// - NOTE: Method prepends project ID to path components automatically.
    private func url(with additionalPathComponents: [String], additionalData: [String: String]?) throws -> URL {
        let configuration = configuration.wrappedValue
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

    func replace(configuration: POAlternativePaymentsServiceConfiguration) {
        self.configuration.withLock { $0 = configuration }
    }

    // MARK: - Response

    private func response(from url: URL) throws -> POAlternativePaymentResponse {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            let message = "Invalid or malformed alternative payment method URL response provided."
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
