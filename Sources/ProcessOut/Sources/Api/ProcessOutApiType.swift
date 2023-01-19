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

    /// Images repository.
    var images: POImagesRepositoryType { get }

    /// Returns Alternative Payment Methods service.
    var alternativePaymentMethods: POAlternativePaymentMethodsServiceType { get }

    /// Returns cards repository.
    @_spi(PO)
    var cards: POCardsRepositoryType { get }

    /// Returns customer tokens service.
    @_spi(PO)
    var customerTokens: POCustomerTokensServiceType { get }
}

extension ProcessOutApiType {

    var cards: POCardsRepositoryType {
        fatalError("Not available!")
    }

    var customerTokens: POCustomerTokensServiceType {
        fatalError("Not available!")
    }
}
