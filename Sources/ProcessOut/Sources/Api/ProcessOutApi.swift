//
//  ProcessOutApi.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.10.2022.
//

import Foundation
import UIKit

/// Class that provides access to shared api instance and a way to configure it.
public enum ProcessOutApi {

    /// Shared instance.
    public private(set) static var shared: ProcessOutApiType! // swiftlint:disable:this implicitly_unwrapped_optional

    /// Configures ``ProcessOutApi/shared`` instance.
    /// - NOTE: Method must be called from main thread. Only the first invocation takes effect, all
    /// subsequent calls to this method are ignored.
    public static func configure(configuration: ProcessOutApiConfiguration) {
        assert(Thread.isMainThread, "Method must be called only from main thread")
        if let shared {
            shared.logger.info("ProcessOutApi can be configured only once, ignored")
            return
        }
        shared = SharedProcessOutApi(configuration: configuration)
        shared.logger.debug("Did complete ProcessOutApi configuration")
    }
}

private final class SharedProcessOutApi: ProcessOutApiType {

    init(configuration: ProcessOutApiConfiguration) {
        self.configuration = configuration
    }

    // MARK: - ProcessOutApiType

    let configuration: ProcessOutApiConfiguration

    private(set) lazy var gatewayConfigurations: POGatewayConfigurationsRepositoryType = {
        GatewayConfigurationsRepository(connector: httpConnector, failureMapper: failureMapper)
    }()

    private(set) lazy var invoices: POInvoicesServiceType = {
        let repository = InvoicesRepository(connector: httpConnector, failureMapper: failureMapper)
        return InvoicesService(repository: repository, customerActionHandler: customerActionHandler)
    }()

    private(set) lazy var images: POImagesRepositoryType = {
        ImagesRepository(session: .shared)
    }()

    private(set) lazy var alternativePaymentMethods: POAlternativePaymentMethodsServiceType = {
        AlternativePaymentMethodsService(
            projectId: configuration.projectId, baseUrl: configuration.checkoutBaseUrl, logger: serviceLogger
        )
    }()

    private(set) lazy var logger: POLogger = createLogger(for: "Application")

    private(set) lazy var cards: POCardsRepositoryType = {
        CardsRepository(
            connector: httpConnector,
            failureMapper: failureMapper,
            applePayCardTokenizationRequestMapper: ApplePayCardTokenizationRequestMapper(
                decoder: decoder, logger: repositoryLogger
            )
        )
    }()

    private(set) lazy var customerTokens: POCustomerTokensServiceType = {
        let repository = CustomerTokensRepository(connector: httpConnector, failureMapper: failureMapper)
        return CustomerTokensService(repository: repository, customerActionHandler: customerActionHandler)
    }()

    private(set) lazy var eventEmitter: POEventEmitterType = EventEmitter()

    func processDeepLink(url: URL) -> Bool {
        let event = DeepLinkReceivedEvent(url: url)
        return eventEmitter.emit(event: event)
    }

    // MARK: - Private Properties

    private lazy var serviceLogger = createLogger(for: "Service")
    private lazy var repositoryLogger = createLogger(for: "Repository")

    private lazy var httpConnector: HttpConnectorType = {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.urlCache = nil
        sessionConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData
        sessionConfiguration.waitsForConnectivity = true
        sessionConfiguration.timeoutIntervalForRequest = 30
        let connector = HttpConnector(
            configuration: .init(
                baseUrl: configuration.apiBaseUrl,
                projectId: configuration.projectId,
                privateKey: configuration.privateKey,
                version: Self.version
            ),
            sessionConfiguration: sessionConfiguration,
            decoder: decoder,
            encoder: encoder,
            deviceMetadataProvider: DeviceMetadataProvider(screen: UIScreen.main, bundle: Bundle.main),
            logger: createLogger(for: "Connector")
        )
        let retryStrategy = RetryStrategy.exponential(maximumRetries: 3, interval: 0.1, rate: 3)
        return HttpConnectorRetryDecorator(connector: connector, retryStrategy: retryStrategy)
    }()

    private lazy var failureMapper = HttpConnectorFailureMapper(logger: repositoryLogger)

    private lazy var customerActionHandler: ThreeDSCustomerActionHandlerType = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        let encoder = JSONEncoder()
        encoder.dataEncodingStrategy = .base64
        encoder.keyEncodingStrategy = .useDefaultKeys
        return ThreeDSCustomerActionHandler(decoder: decoder, encoder: encoder, logger: serviceLogger)
    }()

    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()

    private lazy var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        return encoder
    }()

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }()

    // MARK: - Private Methods

    private func createLogger(for category: String) -> POLogger {
        let destinations: [LoggerDestination] = [
            SystemLoggerDestination(subsystem: "com.processout.processout-ios", category: category)
        ]
        let minimumLevel: LogLevel = configuration.isDebug ? .debug : .info
        return POLogger(destinations: destinations, minimumLevel: minimumLevel)
    }
}
