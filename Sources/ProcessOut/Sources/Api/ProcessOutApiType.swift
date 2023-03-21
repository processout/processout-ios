//
//  ProcessOutApiType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2022.
//

import Foundation

public protocol ProcessOutApiType {

    /// Current configuration.
    var configuration: ProcessOutApiConfiguration { get }

    /// Returns gateway configurations repository.
    var gatewayConfigurations: POGatewayConfigurationsRepositoryType { get }

    /// Returns invoices service.
    var invoices: POInvoicesServiceType { get }

    /// Images repository.
    var images: POImagesRepositoryType { get }

    /// Returns alternative payment methods service.
    var alternativePaymentMethods: POAlternativePaymentMethodsServiceType { get }

    /// Returns cards repository.
    var cards: POCardsServiceType { get }

    /// Returns customer tokens service.
    var customerTokens: POCustomerTokensServiceType { get }

    /// Event emitter to use for for events exchange.
    var eventEmitter: POEventEmitterType { get }

    /// Logger with application category.
    var logger: POLogger { get }

    /// Call this method in your app or scene delegate whenever you incoming URL. You can path both custom scheme-based
    /// deep links and universal links.
    ///
    /// - Returns: `true` if the URL is expected and will be handled by SDK. `false` otherwise.
    @discardableResult
    func processDeepLink(url: URL) -> Bool
}
