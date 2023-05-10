//
//  ProcessOutApiType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2022.
//

import Foundation

// todo(andrii-vysotskyi): remove suffix before releasing version 4.0.0
public protocol ProcessOutApiType {

    /// Current configuration.
    var configuration: ProcessOutApiConfiguration { get }

    /// Returns gateway configurations repository.
    var gatewayConfigurations: POGatewayConfigurationsRepository { get }

    /// Returns invoices service.
    var invoices: POInvoicesService { get }

    /// Images repository.
    var images: POImagesRepository { get }

    /// Returns alternative payment methods service.
    var alternativePaymentMethods: POAlternativePaymentMethodsService { get }

    /// Returns cards repository.
    var cards: POCardsService { get }

    /// Returns customer tokens service.
    var customerTokens: POCustomerTokensService { get }

    /// Logger with application category.
    var logger: POLogger { get }

    /// Event emitter to use for for events exchange.
    var eventEmitter: POEventEmitter { get }

    /// Call this method in your app or scene delegate whenever your implementation receives incoming URL. You can pass
    /// both custom scheme-based deep links and universal links.
    ///
    /// - Returns: `true` if the URL is expected and will be handled by SDK. `false` otherwise.
    @discardableResult
    func processDeepLink(url: URL) -> Bool
}
