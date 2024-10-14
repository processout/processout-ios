//
//  ProcessOut.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.10.2024.
//

// swiftlint:disable force_unwrapping

import Foundation
import UIKit

@available(*, deprecated, renamed: "ProcessOut")
public typealias ProcessOutApi = ProcessOut

/// Provides access to shared api instance and a way to configure it.
public final class ProcessOut: @unchecked Sendable {

    /// Current configuration.
    public var configuration: ProcessOutConfiguration {
        _configuration.wrappedValue
    }

    /// Returns gateway configurations repository.
    public let gatewayConfigurations: POGatewayConfigurationsRepository

    /// Invoices service.
    public let invoices: POInvoicesService

    /// Alternative payments service.
    public let alternativePayments: POAlternativePaymentsService

    /// Cards service.
    public let cards: POCardsService

    /// Returns customer tokens service.
    public let customerTokens: POCustomerTokensService

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

    /// Images repository.
    @_spi(PO)
    public let images: POImagesRepository = UrlSessionImagesRepository(session: .shared)

    /// Logger with application category.
    @_spi(PO)
    public let logger: POLogger

    /// Event emitter to use for events exchange.
    @_spi(PO)
    public let eventEmitter: POEventEmitter

    // MARK: - Internal

    func replace(configuration newConfiguration: ProcessOutConfiguration) {
        _configuration.withLock { configuration in
            replaceLoggersConfiguration(with: newConfiguration)
            replaceConnectorsConfiguration(with: newConfiguration)
            replaceServicesConfiguration(with: newConfiguration)
            configuration = newConfiguration
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let applicationLoggerCategory = "Application"
        static let serviceLoggerCategory = "Service"
        static let connectorLoggerCategory = "Connector"
        static let bundleIdentifier = "com.processout.processout-ios"
    }

    // MARK: - Private Properties

    private let telemetryService: TelemetryService
    private let httpConnector: HttpConnector
    private let telemetryHttpConnector: HttpConnector
    private let serviceLogger: POLogger
    private let connectorLogger: POLogger
    private let telemetryConnectorLogger: POLogger
    private let _configuration: POUnfairlyLocked<ProcessOutConfiguration>

    // MARK: - Private Methods

    @MainActor
    private init(configuration: ProcessOutConfiguration) {
        self._configuration = .init(wrappedValue: configuration)
        let deviceMetadataProvider = Self.createDeviceMetadataProvider()
        // Telemetry connector logs are not submitted to backend to avoid recursion.
        telemetryConnectorLogger = Self.createLogger(
            for: Constants.connectorLoggerCategory, configuration: configuration
        )
        telemetryHttpConnector = Self.createConnector(
            configuration: configuration,
            deviceMetadataProvider: deviceMetadataProvider,
            logger: telemetryConnectorLogger
        )
        telemetryService = Self.createTelemetryService(
            configuration: configuration,
            deviceMetadataProvider: deviceMetadataProvider,
            connector: telemetryHttpConnector
        )
        serviceLogger = Self.createLogger(
            for: Constants.serviceLoggerCategory,
            configuration: configuration,
            additionalDestinations: telemetryService
        )
        connectorLogger = Self.createLogger(
            for: Constants.connectorLoggerCategory,
            configuration: configuration,
            additionalDestinations: telemetryService
        )
        httpConnector = Self.createConnector(
            configuration: configuration,
            deviceMetadataProvider: deviceMetadataProvider,
            logger: connectorLogger
        )
        let customerActionsService = Self.createCustomerActionsService(logger: serviceLogger)
        gatewayConfigurations = HttpGatewayConfigurationsRepository(connector: httpConnector)
        invoices = Self.createInvoicesService(
            httpConnector: httpConnector, customerActionsService: customerActionsService, logger: serviceLogger
        )
        alternativePayments = Self.createAlternativePaymentsService(
            configuration: configuration, logger: serviceLogger
        )
        cards = Self.createCardsService(
            httpConnector: httpConnector, logger: serviceLogger
        )
        customerTokens = Self.createCustomerTokensService(
            httpConnector: httpConnector, customerActionsService: customerActionsService, logger: serviceLogger
        )
        logger = Self.createLogger(
            for: Constants.applicationLoggerCategory,
            configuration: configuration,
            additionalDestinations: telemetryService
        )
        eventEmitter = LocalEventEmitter(logger: logger)
    }

    // MARK: - Services

    private static func createInvoicesService(
        httpConnector: HttpConnector, customerActionsService: CustomerActionsService, logger: POLogger
    ) -> POInvoicesService {
        let repository = HttpInvoicesRepository(connector: httpConnector)
        return DefaultInvoicesService(
            repository: repository, customerActionsService: customerActionsService, logger: logger
        )
    }

    private static func createAlternativePaymentsService(
        configuration: ProcessOutConfiguration, logger: POLogger
    ) -> POAlternativePaymentsService {
        let serviceConfiguration = Self.alternativePaymentsConfiguration(with: configuration)
        let webSession = DefaultWebAuthenticationSession()
        return DefaultAlternativePaymentsService(
            configuration: serviceConfiguration, webSession: webSession, logger: logger
        )
    }

    private static func alternativePaymentsConfiguration(
        with configuration: ProcessOutConfiguration
    ) -> POAlternativePaymentsServiceConfiguration {
        .init(projectId: configuration.projectId, baseUrl: configuration.environment.checkoutBaseUrl)
    }

    private static func createCardsService(httpConnector: HttpConnector, logger: POLogger) -> POCardsService {
        let contactMapper = DefaultPassKitContactMapper(logger: logger)
        let requestMapper = DefaultApplePayCardTokenizationRequestMapper(
            contactMapper: contactMapper, decoder: JSONDecoder(), logger: logger
        )
        let service = DefaultCardsService(
            repository: HttpCardsRepository(connector: httpConnector),
            applePayAuthorizationSession: DefaultApplePayAuthorizationSession(),
            applePayCardTokenizationRequestMapper: requestMapper,
            applePayErrorMapper: PODefaultPassKitPaymentErrorMapper(logger: logger)
        )
        return service
    }

    private static func createCustomerTokensService(
        httpConnector: HttpConnector, customerActionsService: CustomerActionsService, logger: POLogger
    ) -> POCustomerTokensService {
        let repository = HttpCustomerTokensRepository(connector: httpConnector)
        return DefaultCustomerTokensService(
            repository: repository, customerActionsService: customerActionsService, logger: logger
        )
    }

    private static func createCustomerActionsService(logger: POLogger) -> CustomerActionsService {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        let encoder = JSONEncoder()
        encoder.dataEncodingStrategy = .base64
        encoder.keyEncodingStrategy = .useDefaultKeys
        let webSession = DefaultWebAuthenticationSession()
        return DefaultCustomerActionsService(decoder: decoder, encoder: encoder, webSession: webSession, logger: logger)
    }

    private static func createTelemetryService(
        configuration: ProcessOutConfiguration,
        deviceMetadataProvider: DeviceMetadataProvider,
        connector: HttpConnector
    ) -> DefaultTelemetryService {
        let serviceConfiguration = telemetryConfiguration(with: configuration)
        let repository = DefaultTelemetryRepository(connector: connector)
        return DefaultTelemetryService(
            configuration: serviceConfiguration, repository: repository, deviceMetadataProvider: deviceMetadataProvider
        )
    }

    private static func telemetryConfiguration(
        with configuration: ProcessOutConfiguration
    ) -> TelemetryServiceConfiguration {
        .init(
            isTelemetryEnabled: configuration.isTelemetryEnabled,
            applicationVersion: configuration.application?.version,
            applicationName: configuration.application?.name
        )
    }

    @MainActor
    private static func createDeviceMetadataProvider() -> DeviceMetadataProvider {
        let keychain = Keychain(service: Constants.bundleIdentifier)
        return DefaultDeviceMetadataProvider(screen: .main, device: .current, bundle: .main, keychain: keychain)
    }

    // MARK: - Connectors

    private static func createConnector(
        configuration: ProcessOutConfiguration,
        deviceMetadataProvider: DeviceMetadataProvider,
        logger: POLogger
    ) -> HttpConnector {
        let connector = ProcessOutHttpConnectorBuilder()
            .with(configuration: connectorConfiguration(with: configuration))
            .with(logger: logger)
            .with(deviceMetadataProvider: deviceMetadataProvider)
            .build()
        return connector
    }

    private static func connectorConfiguration(
        with configuration: ProcessOutConfiguration
    ) -> HttpConnectorConfiguration {
        .init(
            baseUrl: configuration.environment.apiBaseUrl,
            projectId: configuration.projectId,
            privateKey: configuration.privateKey,
            sessionId: configuration.sessionId,
            version: ProcessOut.version
        )
    }

    // MARK: - Loggers

    private static func createLogger(
        for category: String, configuration: ProcessOutConfiguration, additionalDestinations: LoggerDestination?...
    ) -> POLogger {
        var destinations: [LoggerDestination] = [
            SystemLoggerDestination(subsystem: Constants.bundleIdentifier)
        ]
        destinations.append(
            contentsOf: additionalDestinations.compactMap { $0 }
        )
        let minimumLevel = minimumLogLevel(with: configuration)
        return POLogger(destinations: destinations, category: category, minimumLevel: minimumLevel)
    }

    private static func minimumLogLevel(with configuration: ProcessOutConfiguration) -> LogLevel {
        configuration.isDebug ? .debug : .info
    }

    // MARK: - Configuration Update

    private func replaceServicesConfiguration(with configuration: ProcessOutConfiguration) {
        alternativePayments.replace(configuration: Self.alternativePaymentsConfiguration(with: configuration))
        telemetryService.replace(configuration: Self.telemetryConfiguration(with: configuration))
    }

    private func replaceConnectorsConfiguration(with configuration: ProcessOutConfiguration) {
        let logLevel = Self.minimumLogLevel(with: configuration)
        telemetryConnectorLogger.replace(minimumLevel: logLevel)
        connectorLogger.replace(minimumLevel: logLevel)
        serviceLogger.replace(minimumLevel: logLevel)
        logger.replace(minimumLevel: logLevel)
    }

    private func replaceLoggersConfiguration(with configuration: ProcessOutConfiguration) {
        let connectorConfiguration = Self.connectorConfiguration(with: configuration)
        httpConnector.replace(configuration: connectorConfiguration)
        telemetryHttpConnector.replace(configuration: connectorConfiguration)
    }
}

extension ProcessOut {

    /// Returns alternative payment methods service.
    @available(*, deprecated, renamed: "alternativePayments")
    public var alternativePaymentMethods: POAlternativePaymentsService {
        alternativePayments
    }
}

// MARK: - Singleton

extension ProcessOut {

    /// Returns boolean value indicating whether SDK is configured and operational.
    public static var isConfigured: Bool {
        _shared.wrappedValue != nil
    }

    /// Shared instance.
    public static var shared: ProcessOut {
        precondition(isConfigured, "ProcessOut must be configured before the shared instance is accessed.")
        return _shared.wrappedValue!
    }

    /// Configures ``ProcessOut/shared`` instance.
    /// - Parameters:
    ///   - configuration: configuration.
    ///   - force: When set to `false` (the default) only the first invocation takes effect, all
    /// subsequent calls to this method are ignored. Pass `true` to allow existing shared instance
    /// reconfiguration (if any).
    public static func configure(configuration: ProcessOutConfiguration, force: Bool = false) {
        // todo(andrii-vysotskyi): isolate method to main actor when releasing 5.0.0
        MainActor.assumeIsolated {
            if isConfigured {
                if force {
                    shared.replace(configuration: configuration)
                    shared.logger.debug("Did change ProcessOut configuration")
                } else {
                    shared.logger.debug("ProcessOut can be configured only once, ignored")
                }
            } else {
                Self.prewarm()
                _shared.withLock { instance in
                    instance = ProcessOut(configuration: configuration)
                }
                shared.logger.debug("Did complete ProcessOut configuration")
            }
        }
    }

    // MARK: - Private Properties

    private static let _shared = POUnfairlyLocked<ProcessOut?>(wrappedValue: nil)

    // MARK: - Private Methods

    private static func prewarm() {
        FontFamily.registerAllCustomFonts()
        PODefaultPhoneNumberMetadataProvider.shared.prewarm()
    }
}

// swiftlint:enable force_unwrapping
