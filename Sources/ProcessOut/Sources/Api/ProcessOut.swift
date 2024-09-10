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

    /// Current configuration.
    public var configuration: ProcessOutConfiguration {
        _configuration
    }

    /// Returns gateway configurations repository.
    public private(set) lazy var gatewayConfigurations: POGatewayConfigurationsRepository = {
        HttpGatewayConfigurationsRepository(connector: httpConnector)
    }()

    /// Returns invoices service.
    public private(set) lazy var invoices: POInvoicesService = {
        let repository = HttpInvoicesRepository(connector: httpConnector)
        return DefaultInvoicesService(repository: repository, threeDSService: threeDSService, logger: serviceLogger)
    }()

    /// Returns alternative payment methods service.
    public private(set) lazy var alternativePaymentMethods: POAlternativePaymentMethodsService = {
        let serviceConfiguration: () -> AlternativePaymentMethodsServiceConfiguration = { [unowned self] in
            let configuration = self.configuration
            return .init(projectId: configuration.projectId, baseUrl: configuration.environment.checkoutBaseUrl)
        }
        return DefaultAlternativePaymentMethodsService(configuration: serviceConfiguration, logger: serviceLogger)
    }()

    /// Returns cards repository.
    public private(set) lazy var cards: POCardsService = {
        let requestMapper = DefaultApplePayCardTokenizationRequestMapper(
            contactMapper: DefaultPassKitContactMapper(logger: serviceLogger),
            decoder: JSONDecoder(),
            logger: serviceLogger
        )
        let service = DefaultCardsService(
            repository: HttpCardsRepository(connector: httpConnector),
            applePayAuthorizationSession: DefaultApplePayAuthorizationSession(),
            applePayCardTokenizationRequestMapper: requestMapper,
            applePayErrorMapper: PODefaultPassKitPaymentErrorMapper(logger: serviceLogger)
        )
        return service
    }()

    /// Returns customer tokens service.
    public private(set) lazy var customerTokens: POCustomerTokensService = {
        let repository = HttpCustomerTokensRepository(connector: httpConnector)
        return DefaultCustomerTokensService(
            repository: repository, threeDSService: threeDSService, logger: serviceLogger
        )
    }()

    /// Call this method in your app or scene delegate whenever your implementation receives incoming URL. Only deep
    /// links are supported.
    ///
    /// - Returns: `true` if the URL is expected and will be handled by SDK. `false` otherwise.
    @discardableResult
    public func processDeepLink(url: URL) -> Bool {
        logger.debug("Will process deep link: \(url)")
        return eventEmitter.emit(event: PODeepLinkReceivedEvent(url: url))
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

    // MARK: - Private Nested Types

    private enum Constants {
        static let applicationLoggerCategory = "Application"
        static let serviceLoggerCategory = "Service"
        static let repositoryLoggerCategory = "Repository"
        static let connectorLoggerCategory = "Connector"
        static let bundleIdentifier = "com.processout.processout-ios"
    }

    // MARK: - Private Properties

    @POUnfairlyLocked
    private var _configuration: ProcessOutConfiguration

    private lazy var serviceLogger: POLogger = {
        createLogger(for: Constants.serviceLoggerCategory)
    }()

    private lazy var deviceMetadataProvider: DefaultDeviceMetadataProvider = {
        let keychain = Keychain(service: Constants.bundleIdentifier)
        return DefaultDeviceMetadataProvider(screen: .main, device: .current, bundle: .main, keychain: keychain)
    }()

    private lazy var httpConnector: HttpConnector = {
        createConnector(includeLoggerRemoteDestination: true)
    }()

    private lazy var remoteLoggerDestination: LoggerDestination = {
        let configuration: () -> TelemetryServiceConfiguration = { [unowned self] in
            let configuration = self.configuration
            return TelemetryServiceConfiguration(
                isTelemetryEnabled: configuration.isTelemetryEnabled,
                applicationVersion: configuration.application?.version,
                applicationName: configuration.application?.name
            )
        }
        // Telemetry service uses repository with "special" connector. Its logs
        // are not submitted to backend to avoid recursion.
        let repository = DefaultTelemetryRepository(
            connector: createConnector(includeLoggerRemoteDestination: false)
        )
        return DefaultTelemetryService(
            configuration: configuration, repository: repository, deviceMetadataProvider: deviceMetadataProvider
        )
    }()

    private lazy var threeDSService: ThreeDSService = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        let encoder = JSONEncoder()
        encoder.dataEncodingStrategy = .base64
        encoder.keyEncodingStrategy = .useDefaultKeys
        return DefaultThreeDSService(decoder: decoder, encoder: encoder)
    }()

    // MARK: - Private Methods

    private init(configuration: ProcessOutConfiguration) {
        self.__configuration = .init(wrappedValue: configuration)
    }

    private func createConnector(includeLoggerRemoteDestination: Bool) -> HttpConnector {
        let connectorConfiguration = { [unowned self] in
            let configuration = self.configuration
            return HttpConnectorRequestMapperConfiguration(
                baseUrl: configuration.environment.apiBaseUrl,
                projectId: configuration.projectId,
                privateKey: configuration.privateKey,
                sessionId: configuration.sessionId,
                version: ProcessOut.version
            )
        }
        let logger = createLogger(
            for: Constants.connectorLoggerCategory,
            includeRemoteDestination: includeLoggerRemoteDestination
        )
        let connector = ProcessOutHttpConnectorBuilder()
            .with(configuration: connectorConfiguration)
            .with(logger: logger)
            .with(deviceMetadataProvider: deviceMetadataProvider)
            .build()
        return connector
    }

    private func createLogger(for category: String, includeRemoteDestination: Bool = true) -> POLogger {
        var destinations: [LoggerDestination] = [
            SystemLoggerDestination(subsystem: Constants.bundleIdentifier)
        ]
        if includeRemoteDestination {
            destinations.append(remoteLoggerDestination)
        }
        let minimumLevel: () -> LogLevel = { [unowned self] in
            configuration.isDebug ? .debug : .info
        }
        return POLogger(destinations: destinations, category: category, minimumLevel: minimumLevel)
    }
}

// MARK: - Singleton

extension ProcessOut {

    /// Returns boolean value indicating whether SDK is configured and operational.
    public static var isConfigured: Bool {
        _shared != nil
    }

    /// Shared instance.
    public static var shared: ProcessOut {
        precondition(isConfigured, "ProcessOut must be configured before the shared instance is accessed.")
        return _shared
    }

    /// Configures ``ProcessOut/shared`` instance.
    /// - Parameters:
    ///   - force: When set to `false` (the default) only the first invocation takes effect, all
    /// subsequent calls to this method are ignored. Pass `true` to allow existing shared instance
    /// reconfiguration (if any).
    public static func configure(configuration: ProcessOutConfiguration, force: Bool = false) {
        assert(Thread.isMainThread, "Method must be called only from main thread")
        if isConfigured {
            if force {
                shared.$_configuration.withLock { $0 = configuration }
                shared.logger.debug("Did change ProcessOut configuration")
            } else {
                shared.logger.debug("ProcessOut can be configured only once, ignored")
            }
        } else {
            Self.prewarm()
            _shared = ProcessOut(configuration: configuration)
            shared.logger.debug("Did complete ProcessOut configuration")
        }
    }

    // MARK: - Private Properties

    private static var _shared: ProcessOut! // swiftlint:disable:this implicitly_unwrapped_optional

    // MARK: - Private Methods

    private static func prewarm() {
        FontFamily.registerAllCustomFonts()
        PODefaultPhoneNumberMetadataProvider.shared.prewarm()
    }
}
