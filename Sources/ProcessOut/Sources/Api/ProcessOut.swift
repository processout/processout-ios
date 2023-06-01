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
        let configuration = HttpConnectorRequestMapperConfiguration(
            baseUrl: configuration.apiBaseUrl,
            projectId: configuration.projectId,
            privateKey: configuration.privateKey,
            version: ProcessOut.version,
            appVersion: configuration.appVersion
        )
        // Connector logs are not sent to backend to avoid recursion. This
        // may be not ideal because we may loose important events, such
        // as decoding failures so approach may be reconsidered in future.
        let connector = ProcessOutHttpConnectorBuilder()
            .with(configuration: configuration)
            .with(logger: createLogger(for: Constants.connectorLoggerCategory, includeRemoteDestination: false))
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

    private func createLogger(for category: String, includeRemoteDestination: Bool = true) -> POLogger {
        var destinations: [LoggerDestination] = [
            SystemLoggerDestination(subsystem: Constants.systemLoggerSubsystem)
        ]
        if includeRemoteDestination {
            let repository = HttpLogsRepository(connector: httpConnector)
            let service = DefaultLogsService(repository: repository, minimumLevel: .error)
            destinations.append(service)
        }
        let minimumLevel: LogLevel = configuration.isDebug ? .debug : .info
        return POLogger(destinations: destinations, category: category, minimumLevel: minimumLevel)
    }

    private func prewarm() {
        DefaultPhoneNumberMetadataProvider.shared.prewarm()
    }
}

@available(*, deprecated, message: "Use ProcessOut directly")
extension ProcessOut: ProcessOutApiType { }
