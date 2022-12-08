//
//  ProcessOutApi.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.10.2022.
//

import Foundation
import UIKit

/// Class that provides access to shared api instance and a way to configure it.
public final class ProcessOutApi: ProcessOutApiType {

    /// Shared instance.
    public private(set) static var shared: ProcessOutApiType! // swiftlint:disable:this implicitly_unwrapped_optional

    /// Configures ``ProcessOutApi/shared`` instance.
    public static func configure(configuration: ProcessOutApiConfiguration) {
        assert(Thread.isMainThread)
        guard shared == nil else {
            assertionFailure("Already configured.")
            return
        }
        let connector = createHttpConnector(configuration: configuration)
        let failureMapper = FailureMapper()
        shared = ProcessOutApi(
            configuration: configuration,
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
            alternativePaymentMethods: AlternativePaymentMethodsService(
                projectId: configuration.projectId, baseUrl: configuration.checkoutBaseUrl
            ),
            images: ImagesRepository(session: .shared)
        )
    }

    // MARK: - ProcessOutApiType

    public let configuration: ProcessOutApiConfiguration
    public let gatewayConfigurations: POGatewayConfigurationsRepositoryType
    public let invoices: POInvoicesServiceType
    public let cards: POCardsRepositoryType
    public let customerTokens: POCustomerTokensServiceType
    public let alternativePaymentMethods: POAlternativePaymentMethodsServiceType
    public let images: POImagesRepositoryType

    // MARK: -

    private init(
        configuration: ProcessOutApiConfiguration,
        gatewayConfigurations: POGatewayConfigurationsRepositoryType,
        invoices: POInvoicesServiceType,
        cards: POCardsRepositoryType,
        customerTokens: POCustomerTokensServiceType,
        alternativePaymentMethods: POAlternativePaymentMethodsServiceType,
        images: POImagesRepositoryType
    ) {
        self.configuration = configuration
        self.gatewayConfigurations = gatewayConfigurations
        self.invoices = invoices
        self.cards = cards
        self.customerTokens = customerTokens
        self.alternativePaymentMethods = alternativePaymentMethods
        self.images = images
    }

    // MARK: - Private Methods

    private static func createHttpConnector(configuration: ProcessOutApiConfiguration) -> HttpConnectorType {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.urlCache = nil
        sessionConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData
        sessionConfiguration.waitsForConnectivity = true
        sessionConfiguration.timeoutIntervalForRequest = 30
        let connector = HttpConnector(
            configuration: .init(
                baseUrl: configuration.apiBaseUrl,
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
