//
//  AlternativePaymentMethodsService.swift
//  ProcessOut
//
//  Created by Simeon Kostadinov on 27/10/2022.
//

import Foundation

final class AlternativePaymentMethodsService: POAlternativePaymentMethodsServiceType {

    init(projectId: String, baseUrl: URL, logger: POLogger) {
        self.projectId = projectId
        self.baseUrl = baseUrl
        self.logger = logger
    }

    // MARK: - POAlternativePaymentMethodsServiceType

    func alternativePaymentMethodUrl(request: POAlternativePaymentMethodRequest) -> URL {
        guard var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true) else {
            let message = "Can't create components from base url."
            logger.error("\(message)")
            fatalError(message)
        }
        let pathComponents: [String]
        if let tokenId = request.tokenId, let customerId = request.customerId {
            pathComponents = [projectId, customerId, tokenId, "redirect", request.gatewayConfigurationId]
        } else {
            pathComponents = [projectId, request.invoiceId, "redirect", request.gatewayConfigurationId]
        }
        components.path = "/" + pathComponents.joined(separator: "/")
        components.queryItems = request.additionalData?.map { data in
            URLQueryItem(name: "additional_data[" + data.key + "]", value: data.value)
        }
        guard let url = components.url else {
            let message = "Failed to create APM redirection URL."
            logger.error("\(message)")
            fatalError(message)
        }
        return url
    }

    func alternativePaymentMethodResponse(url: URL) throws -> POAlternativePaymentMethodResponse {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            let message = "Invalid or malformed Alternative Payment Mehod URL response provided."
            throw POFailure(message: message, code: .internal, underlyingError: nil)
        }
        if let errorCode = queryItems.queryItemValue(name: "error_code") {
            throw POFailure(code: createFailureCode(rawValue: errorCode))
        }
        guard let gatewayToken = queryItems.queryItemValue(name: "token") else {
            let message = "Invalid or malformed Alternative Payment Mehod URL response provided."
            throw POFailure(message: message, code: .internal, underlyingError: nil)
        }
        guard let customerId = queryItems.queryItemValue(name: "customer_id"),
              let tokenId = queryItems.queryItemValue(name: "token_id") else {
            return .init(gatewayToken: gatewayToken, customerId: nil, tokenId: nil, returnType: .authorization)
        }
        return .init(gatewayToken: gatewayToken, customerId: customerId, tokenId: tokenId, returnType: .createToken)
    }

    // MARK: - Private

    private let projectId: String
    private let baseUrl: URL
    private let logger: POLogger

    // MARK: - Private Methods

    private func createFailureCode(rawValue: String) -> POFailure.Code {
        if let validationCode = POFailure.ValidationCode(rawValue: rawValue) {
            return .validation(validationCode)
        } else if let authenticationCode = POFailure.AuthenticationCode(rawValue: rawValue) {
            return .authentication(authenticationCode)
        } else if let notFoundCode = POFailure.NotFoundCode(rawValue: rawValue) {
            return .notFound(notFoundCode)
        } else if let genericCode = POFailure.GenericCode(rawValue: rawValue) {
            return .generic(genericCode)
        }
        logger.info("Unknown error value '\(rawValue)'.")
        return .unknown
    }
}

private extension Array where Element == URLQueryItem { // swiftlint:disable:this no_extension_access_modifier

    func queryItemValue(name: String) -> String? {
        first { $0.name == name }?.value
    }
}
