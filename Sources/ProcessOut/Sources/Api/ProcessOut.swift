//
//  ProcessOut.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.10.2022.
//

import Foundation
import UIKit

@available(*, deprecated, renamed: "ProcessOut")
public typealias ProcessOutApi = ProcessOut

/// Provides access to shared api instance and a way to configure it.
public final class ProcessOut {

    /// Shared instance.
    public private(set) static var shared: ProcessOut! // swiftlint:disable:this implicitly_unwrapped_optional

    /// Configures ``ProcessOut/shared`` instance.
    /// - NOTE: Method must be called from main thread. Only the first invocation takes effect, all
    /// subsequent calls to this method are ignored.
    public static func configure(configuration: ProcessOutConfiguration) {
        assert(Thread.isMainThread, "Method must be called only from main thread")
        if let shared {
            shared.logger.info("ProcessOut can be configured only once, ignored")
            return
        }
        shared = ProcessOut(configuration: configuration)
        shared.prewarm()
        shared.logger.debug("Did complete ProcessOut configuration")
    }

    // MARK: - ProcessOutType

    /// Current configuration.
    public let configuration: ProcessOutConfiguration

    /// Returns gateway configurations repository.
    public private(set) lazy var gatewayConfigurations: POGatewayConfigurationsRepository = {
        HttpGatewayConfigurationsRepository(connector: httpConnector, failureMapper: failureMapper)
    }()

    /// Returns invoices service.
    public private(set) lazy var invoices: POInvoicesService = {
        let repository = HttpInvoicesRepository(connector: httpConnector, failureMapper: failureMapper)
        return DefaultInvoicesService(repository: repository, threeDSService: threeDSService)
    }()

    /// Images repository.
    public private(set) lazy var images: POImagesRepository = {
        UrlSessionImagesRepository(session: .shared)
    }()

    /// Returns alternative payment methods service.
    public private(set) lazy var alternativePaymentMethods: POAlternativePaymentMethodsService = {
        DefaultAlternativePaymentMethodsService(
            projectId: configuration.projectId, baseUrl: configuration.checkoutBaseUrl, logger: serviceLogger
        )
    }()

    /// Returns cards repository.
    public private(set) lazy var cards: POCardsService = {
        let requestMapper = DefaultApplePayCardTokenizationRequestMapper(
            decoder: JSONDecoder(), logger: repositoryLogger
        )
        let service = DefaultCardsService(
            repository: HttpCardsRepository(connector: httpConnector, failureMapper: failureMapper),
            applePayCardTokenizationRequestMapper: requestMapper
        )
        return service
    }()

    /// Returns customer tokens service.
    public private(set) lazy var customerTokens: POCustomerTokensService = {
        let repository = HttpCustomerTokensRepository(connector: httpConnector, failureMapper: failureMapper)
        return DefaultCustomerTokensService(repository: repository, threeDSService: threeDSService)
    }()

    /// Logger with application category.
    public private(set) lazy var logger: POLogger = createLogger(for: Constants.applicationLoggerCategory)

    /// Call this method in your app or scene delegate whenever your implementation receives incoming URL. You can pass
    /// both custom scheme-based deep links and universal links.
    ///
    /// - Returns: `true` if the URL is expected and will be handled by SDK. `false` otherwise.
    @discardableResult
    public func processDeepLink(url: URL) -> Bool {
        let event = DeepLinkReceivedEvent(url: url)
        return eventEmitter.emit(event: event)
    }

    // MARK: - Internal

    /// Event emitter to use for events exchange.
    private(set) lazy var eventEmitter: EventEmitter = LocalEventEmitter()

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
            version: ProcessOut.version
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

    private init(configuration: ProcessOutConfiguration) {
        self.configuration = configuration
    }

    private func createLogger(for category: String) -> POLogger {
        let destinations: [LoggerDestination] = [
            SystemLoggerDestination(subsystem: Constants.systemLoggerSubsystem, category: category)
        ]
        let minimumLevel: LogLevel = configuration.isDebug ? .debug : .info
        return POLogger(destinations: destinations, minimumLevel: minimumLevel)
    }

    private func prewarm() {
        FontFamily.registerAllCustomFonts()
        DefaultPhoneNumberMetadataProvider.shared.prewarm()
    }
}

@available(*, deprecated, message: "Use ProcessOut directly")
extension ProcessOut: ProcessOutApiType { }
