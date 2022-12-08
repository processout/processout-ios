//
//  ProcessOutApiType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2022.
//

public protocol ProcessOutApiType {

    /// Current configuration.
    var configuration: ProcessOutApiConfiguration { get }

    /// Returns gateway configurations repository.
    var gatewayConfigurations: POGatewayConfigurationsRepositoryType { get }

    /// Returns invoices service.
    var invoices: POInvoicesServiceType { get }

    /// Return cards repository.
    var cards: POCardsRepositoryType { get }

    /// Return customer tokens service.
    var customerTokens: POCustomerTokensServiceType { get }

    /// Return Alternative Payment Methods service.
    var alternativePaymentMethods: POAlternativePaymentMethodsServiceType { get }

    /// Images repository.
    var images: POImagesRepositoryType { get }
}
