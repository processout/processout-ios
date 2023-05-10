//
//  ProcessOutApi.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.10.2022.
//

import Foundation
import UIKit

/// Provides access to shared api instance and a way to configure it.
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

    private(set) lazy var gatewayConfigurations: POGatewayConfigurationsRepository = {
        HttpGatewayConfigurationsRepository(connector: httpConnector, failureMapper: failureMapper)
    }()

    private(set) lazy var invoices: POInvoicesService = {
        let repository = HttpInvoicesRepository(connector: httpConnector, failureMapper: failureMapper)
        return DefaultInvoicesService(repository: repository, threeDSService: threeDSService)
    }()

    private(set) lazy var images: POImagesRepository = {
        UrlSessionImagesRepository(session: .shared)
    }()

    private(set) lazy var alternativePaymentMethods: POAlternativePaymentMethodsService = {
        DefaultAlternativePaymentMethodsService(
            projectId: configuration.projectId, baseUrl: configuration.checkoutBaseUrl, logger: serviceLogger
        )
    }()

    private(set) lazy var logger: POLogger = createLogger(for: Constants.applicationLoggerCategory)

    private(set) lazy var cards: POCardsService = {
        let requestMapper = DefaultApplePayCardTokenizationRequestMapper(
            decoder: JSONDecoder(), logger: repositoryLogger
        )
        let service = DefaultCardsService(
            repository: HttpCardsRepository(connector: httpConnector, failureMapper: failureMapper),
            applePayCardTokenizationRequestMapper: requestMapper
        )
        return service
    }()

    private(set) lazy var customerTokens: POCustomerTokensService = {
        let repository = HttpCustomerTokensRepository(connector: httpConnector, failureMapper: failureMapper)
        return DefaultCustomerTokensService(repository: repository, threeDSService: threeDSService)
    }()

    private(set) lazy var eventEmitter: POEventEmitter = LocalEventEmitter()

    func processDeepLink(url: URL) -> Bool {
        let event = DeepLinkReceivedEvent(url: url)
        return eventEmitter.emit(event: event)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let applicationLoggerCategory = "Application"
        static let serviceLoggerCategory = "Service"
        static let repositoryLoggerCategory = "Repository"
        static let connectorLoggerCategory = "Connector"
        static let systemLoggerSubsystem = "com.processout.processout-ios"
    }

    // MARK: - Private Properties

    private lazy var serviceLogger = createLogger(for: Constants.serviceLoggerCategory)
    private lazy var repositoryLogger = createLogger(for: Constants.repositoryLoggerCategory)

    private lazy var httpConnector: HttpConnector = {
        let connectorConfiguration = HttpConnectorRequestMapperConfiguration(
            baseUrl: configuration.apiBaseUrl,
            projectId: configuration.projectId,
            privateKey: configuration.privateKey,
            version: Self.version
        )
        let connector = ProcessOutHttpConnectorBuilder()
            .with(configuration: connectorConfiguration)
            .with(logger: logger)
            .build()
        return connector
    }()

    private lazy var failureMapper = DefaultHttpConnectorFailureMapper(logger: repositoryLogger)

    private lazy var threeDSService: ThreeDSService = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        let encoder = JSONEncoder()
        encoder.dataEncodingStrategy = .base64
        encoder.keyEncodingStrategy = .useDefaultKeys
        return DefaultThreeDSService(decoder: decoder, encoder: encoder, logger: serviceLogger)
    }()

    // MARK: - Private Methods

    private func createLogger(for category: String) -> POLogger {
        let destinations: [LoggerDestination] = [
            SystemLoggerDestination(subsystem: Constants.systemLoggerSubsystem, category: category)
        ]
        let minimumLevel: LogLevel = configuration.isDebug ? .debug : .info
        return POLogger(destinations: destinations, minimumLevel: minimumLevel)
    }
}
