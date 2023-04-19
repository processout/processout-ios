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
    var configuration: ProcessOutConfiguration { get }

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
}
