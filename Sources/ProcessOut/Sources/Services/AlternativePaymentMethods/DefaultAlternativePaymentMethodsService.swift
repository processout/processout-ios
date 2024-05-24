//
//  DefaultAlternativePaymentMethodsService.swift
//  ProcessOut
//
//  Created by Simeon Kostadinov on 27/10/2022.
//

import Foundation

final class DefaultAlternativePaymentMethodsService: POAlternativePaymentMethodsService {

    init(configuration: @escaping () -> AlternativePaymentMethodsServiceConfiguration, logger: POLogger) {
        self.configuration = configuration
        self.logger = logger
    }

    // MARK: - POAlternativePaymentMethodsService

    func alternativePaymentMethodUrl(request: POAlternativePaymentMethodRequest) -> URL {
        let configuration = self.configuration()
        guard var components = URLComponents(url: configuration.baseUrl, resolvingAgainstBaseURL: true) else {
            preconditionFailure("Failed to create components from base url.")
        }
        let pathComponents: [String]
        if let tokenId = request.tokenId, let customerId = request.customerId {
            pathComponents = [configuration.projectId, customerId, tokenId, "redirect", request.gatewayConfigurationId]
        } else {
            pathComponents = [configuration.projectId, request.invoiceId, "redirect", request.gatewayConfigurationId]
        }
        components.path = "/" + pathComponents.joined(separator: "/")
        components.queryItems = request.additionalData?.map { data in
            URLQueryItem(name: "additional_data[" + data.key + "]", value: data.value)
        }
        guard let url = components.url else {
            preconditionFailure("Failed to create APM redirection URL.")
        }
        return url
    }

    func alternativePaymentMethodResponse(url: URL) throws -> POAlternativePaymentMethodResponse {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            let message = "Invalid or malformed Alternative Payment Method URL response provided."
            throw POFailure(message: message, code: .generic(.mobile), underlyingError: nil)
        }
        let queryItems = components.queryItems ?? []
        if let errorCode = queryItems.queryItemValue(name: "error_code") {
            throw POFailure(code: createFailureCode(rawValue: errorCode))
        }
        let gatewayToken = queryItems.queryItemValue(name: "token")
        if gatewayToken == nil {
            logger.debug("Gateway 'token' is not set in \(url), this may be an error.")
        }
        guard let customerId = queryItems.queryItemValue(name: "customer_id"),
              let tokenId = queryItems.queryItemValue(name: "token_id") else {
            return .init(gatewayToken: gatewayToken ?? "", customerId: nil, tokenId: nil, returnType: .authorization)
        }
        return POAlternativePaymentMethodResponse(
            gatewayToken: gatewayToken ?? "", customerId: customerId, tokenId: tokenId, returnType: .createToken
        )
    }

    // MARK: - Private

    private let configuration: () -> AlternativePaymentMethodsServiceConfiguration
    private let logger: POLogger

    // MARK: - Private Methods

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
