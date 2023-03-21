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

    /// Logger with application category.
    var logger: POLogger { get }

    /// Returns customer tokens service.
    var customerTokens: POCustomerTokensServiceType { get }

    /// Event emitter to use for for events exchange.
    @_spi(PO)
    var eventEmitter: POEventEmitterType { get }

    /// Call this method in your app or scene delegate whenever you incoming URL. You can path both custom scheme-based
    /// deep links and universal links.
    ///
    /// - Returns: `true` if the URL is expected and will be handled by SDK. `false` otherwise.
    @_spi(PO)
    @discardableResult
    func processDeepLink(url: URL) -> Bool
}

extension ProcessOutApiType {

    var eventEmitter: POEventEmitterType {
        fatalError("Not available!")
    }

    func processDeepLink(url: URL) -> Bool { // swiftlint:disable:this unavailable_function
        fatalError("Not available!")
    }
}
