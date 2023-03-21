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

    /// Logger with application category.
    var logger: POLogger { get }
}
