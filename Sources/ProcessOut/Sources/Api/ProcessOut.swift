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
/// - NOTE: Methods and properties of this class **must** be only accessed from main thread.
public final class ProcessOut {

    /// Shared instance.
    public static var shared: ProcessOut {
        precondition(isConfigured, "ProcessOut must be configured before the shared instance is accessed.")
        return _shared
    }

    /// Returns boolean value indicating whether SDK is configured and operational.
    public static var isConfigured: Bool {
        _shared != nil
    }

    /// Configures ``ProcessOut/shared`` instance.
    /// - Parameters:
    ///   - force: When set to `false` (the default) only the first invocation takes effect, all
    /// subsequent calls to this method are ignored. Pass `true` to delete existing shared instance (if any)
    /// and replace it with new one where configuration is set to given value.
    public static func configure(configuration: ProcessOutConfiguration, force: Bool = false) {
        assert(Thread.isMainThread, "Method must be called only from main thread")
        if isConfigured {
            if force {
                _shared = ProcessOut(configuration: configuration)
                shared.logger.debug("Did replace ProcessOut shared instance with new value")
            } else {
                shared.logger.info("ProcessOut can be configured only once, ignored")
            }
        } else {
            Self.prewarm()
            _shared = ProcessOut(configuration: configuration)
            shared.logger.debug("Did complete ProcessOut configuration")
        }
    }

    // MARK: -

    /// Current configuration.
    public let configuration: ProcessOutConfiguration

    /// Returns gateway configurations repository.
    public private(set) lazy var gatewayConfigurations: POGatewayConfigurationsRepository = {
        HttpGatewayConfigurationsRepository(connector: httpConnector)
    }()

    /// Returns invoices service.
    public private(set) lazy var invoices: POInvoicesService = {
        let repository = HttpInvoicesRepository(connector: httpConnector)
        return DefaultInvoicesService(repository: repository, threeDSService: threeDSService)
    }()

    /// Returns alternative payment methods service.
    public private(set) lazy var alternativePaymentMethods: POAlternativePaymentMethodsService = {
        let serviceConfiguration: () -> AlternativePaymentMethodsServiceConfiguration = { [unowned self] in
            .init(projectId: configuration.projectId, baseUrl: configuration.checkoutBaseUrl)
        }
        return DefaultAlternativePaymentMethodsService(configuration: serviceConfiguration, logger: serviceLogger)
    }()

    /// Returns cards repository.
    public private(set) lazy var cards: POCardsService = {
        let requestMapper = DefaultApplePayCardTokenizationRequestMapper(
            decoder: JSONDecoder(), logger: repositoryLogger
        )
        let service = DefaultCardsService(
            repository: HttpCardsRepository(connector: httpConnector),
            applePayCardTokenizationRequestMapper: requestMapper
        )
        return service
    }()

    /// Returns customer tokens service.
    public private(set) lazy var customerTokens: POCustomerTokensService = {
        let repository = HttpCustomerTokensRepository(connector: httpConnector)
        return DefaultCustomerTokensService(repository: repository, threeDSService: threeDSService)
    }()

    /// Call this method in your app or scene delegate whenever your implementation receives incoming URL. Only deep
    /// links are supported.
    ///
    /// - Returns: `true` if the URL is expected and will be handled by SDK. `false` otherwise.
    @discardableResult
    public func processDeepLink(url: URL) -> Bool {
        logger.debug("Will process deep link: \(url)")
        let event = PODeepLinkReceivedEvent(url: url)
        return eventEmitter.emit(event: event)
    }

    // MARK: - SPI

    /// Logger with application category.
    @_spi(PO)
    public private(set) lazy var logger: POLogger = createLogger(for: Constants.applicationLoggerCategory)

    /// Event emitter to use for events exchange.
    @_spi(PO)
    public private(set) lazy var eventEmitter: POEventEmitter = LocalEventEmitter(logger: logger)

    /// Images repository.
    @_spi(PO)
    public private(set) lazy var images: POImagesRepository = UrlSessionImagesRepository(session: .shared)

    // MARK: - Internal

    init(configuration: ProcessOutConfiguration) {
        self.configuration = configuration
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let applicationLoggerCategory = "Application"
        static let serviceLoggerCategory = "Service"
        static let repositoryLoggerCategory = "Repository"
        static let connectorLoggerCategory = "Connector"
        static let bundleIdentifier = "com.processout.processout-ios"
    }

    // MARK: - Private Properties

    private lazy var serviceLogger = createLogger(for: Constants.serviceLoggerCategory)
    private lazy var repositoryLogger = createLogger(for: Constants.repositoryLoggerCategory)

    private lazy var httpConnector: HttpConnector = {
        let configuration = { [unowned self] in
            HttpConnectorRequestMapperConfiguration(
                baseUrl: self.configuration.apiBaseUrl,
                projectId: self.configuration.projectId,
                privateKey: self.configuration.privateKey,
                version: ProcessOut.version,
                appVersion: self.configuration.appVersion
            )
        }
        let keychain = Keychain(service: Constants.bundleIdentifier)
        let deviceMetadataProvider = DefaultDeviceMetadataProvider(
            screen: .main, device: .current, bundle: .main, keychain: keychain
        )
        // Connector logs are not sent to backend to avoid recursion. This
        // may be not ideal because we may loose important events, such
        // as decoding failures so approach may be reconsidered in future.
        let logger = createLogger(for: Constants.connectorLoggerCategory, includeRemoteDestination: false)
        let connector = ProcessOutHttpConnectorBuilder()
            .with(configuration: configuration)
            .with(logger: logger)
            .with(deviceMetadataProvider: deviceMetadataProvider)
            .build()
        return connector
    }()

    private lazy var threeDSService: ThreeDSService = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        let encoder = JSONEncoder()
        encoder.dataEncodingStrategy = .base64
        encoder.keyEncodingStrategy = .useDefaultKeys
        return DefaultThreeDSService(decoder: decoder, encoder: encoder, logger: serviceLogger)
    }()

    private static var _shared: ProcessOut! // swiftlint:disable:this implicitly_unwrapped_optional

    // MARK: - Private Methods

    private func createLogger(for category: String, includeRemoteDestination: Bool = true) -> POLogger {
        let destinations: [LoggerDestination] = [
            SystemLoggerDestination(subsystem: Constants.bundleIdentifier)
        ]
        // todo(andrii-vysotskyi): uncomment code bellow when backend will support accepting SDK logs.
        // if includeRemoteDestination {
        //     let repository = HttpLogsRepository(connector: httpConnector)
        //     let service = DefaultLogsService(repository: repository, minimumLevel: .error)
        //     destinations.append(service)
        // }
        let minimumLevel: () -> LogLevel = { [unowned self] in
            configuration.isDebug ? .debug : .info
        }
        return POLogger(destinations: destinations, category: category, minimumLevel: minimumLevel)
    }

    private static func prewarm() {
        FontFamily.registerAllCustomFonts()
        DefaultPhoneNumberMetadataProvider.shared.prewarm()
    }
}
