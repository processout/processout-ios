//
//  ProcessOutApi.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.10.2022.
//

import Foundation
import UIKit

public final class ProcessOutApi: ProcessOutApiType {

    /// Shared instance.
    public private(set) static var shared: ProcessOutApiType! // swiftlint:disable:this implicitly_unwrapped_optional

    public static func configure(configuration: ProcessOutApiConfiguration) {
        assert(Thread.isMainThread)
        guard shared == nil else {
            assertionFailure("Already configured.")
            return
        }
        let connector = createHttpConnector(configuration: configuration)
        let failureMapper = RepositoryFailureMapper()
        shared = ProcessOutApi(
            gatewayConfigurations: GatewayConfigurationsRepository(
                connector: connector, failureMapper: failureMapper
            ),
            invoices: InvoicesService(
                repository: InvoicesRepository(connector: connector, failureMapper: failureMapper),
                customerActionHandler: customerActionHandler
            ),
            cards: CardsRepository(
                connector: connector,
                failureMapper: failureMapper,
                applePayCardTokenizationRequestMapper: ApplePayCardTokenizationRequestMapper(decoder: decoder)
            ),
            customerTokens: CustomerTokensService(
                repository: CustomerTokensRepository(connector: connector, failureMapper: failureMapper),
                customerActionHandler: customerActionHandler
            ),
            alternativePaymentMethods: createAlternativePaymentMethodsService(configuration: configuration)
        )
    }

    // MARK: - ProcessOutApiType

    public let gatewayConfigurations: POGatewayConfigurationsRepositoryType
    public let invoices: POInvoicesServiceType
    public let cards: POCardsRepositoryType
    public let customerTokens: POCustomerTokensServiceType
    public let alternativePaymentMethods: POAlternativePaymentMethodsServiceType

    // MARK: -

    private init(
        gatewayConfigurations: POGatewayConfigurationsRepositoryType,
        invoices: POInvoicesServiceType,
        cards: POCardsRepositoryType,
        customerTokens: POCustomerTokensServiceType,
        alternativePaymentMethods: POAlternativePaymentMethodsServiceType
    ) {
        self.gatewayConfigurations = gatewayConfigurations
        self.invoices = invoices
        self.cards = cards
        self.customerTokens = customerTokens
        self.alternativePaymentMethods = alternativePaymentMethods
    }

    // MARK: - Private Methods

    private static func createHttpConnector(configuration: ProcessOutApiConfiguration) -> HttpConnectorType {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.urlCache = nil
        sessionConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData
        sessionConfiguration.waitsForConnectivity = true
        sessionConfiguration.timeoutIntervalForRequest = 30
        let baseUrlString: String
        switch configuration.environment {
        case .production:
            baseUrlString = "https://api.processout.com"
        case .staging:
            baseUrlString = "https://api.processout.ninja"
        }
        let connector = HttpConnector(
            configuration: .init(
                baseUrl: URL(string: baseUrlString)!, // swiftlint:disable:this force_unwrapping
                projectId: configuration.projectId,
                password: configuration.password,
                version: Self.version
            ),
            sessionConfiguration: sessionConfiguration,
            decoder: decoder,
            encoder: encoder,
            deviceMetadataProvider: DeviceMetadataProvider(screen: UIScreen.main, bundle: Bundle.main)
        )
        let retryStrategy = RetryStrategy.exponential(maximumRetries: 3, interval: 0.1, rate: 3)
        return HttpConnectorRetryDecorator(connector: connector, retryStrategy: retryStrategy)
    }

    private static func createAlternativePaymentMethodsService(
        configuration: ProcessOutApiConfiguration
    ) -> POAlternativePaymentMethodsServiceType {
        let baseUrlString: String
        switch configuration.environment {
        case .production:
            baseUrlString = "https://checkout.processout.com"
        case .staging:
            baseUrlString = "https://checkout.processout.ninja"
        }
        // swiftlint:disable:next force_unwrapping
        let baseUrl = URL(string: baseUrlString)!
        return AlternativePaymentMethodsService(projectId: configuration.projectId, baseUrl: baseUrl)
    }

    private static let customerActionHandler: CustomerActionHandlerType = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        let encoder = JSONEncoder()
        encoder.dataEncodingStrategy = .base64
        encoder.keyEncodingStrategy = .useDefaultKeys
        return CustomerActionHandler(decoder: decoder, encoder: encoder)
    }()

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        return encoder
    }()

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }()
}
