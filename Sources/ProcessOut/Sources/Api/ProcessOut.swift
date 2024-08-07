//
//  ProcessOut.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.10.2022.
//

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

import Foundation
import UIKit

/// Provides access to shared api instance and a way to configure it.
/// - NOTE: Instance methods and properties of this class could be access from any thread.
public final class ProcessOut: @unchecked Sendable {

    /// Current configuration.
    public var configuration: ProcessOutConfiguration {
        _configuration.wrappedValue
    }

    /// Returns gateway configurations repository.
    public private(set) var gatewayConfigurations: POGatewayConfigurationsRepository!

    /// Invoices service.
    public private(set) var invoices: POInvoicesService!

    /// Alternative payments service.
    public private(set) var alternativePayments: POAlternativePaymentsService!

    /// Cards service.
    public private(set) var cards: POCardsService!

    /// Returns customer tokens service.
    public private(set) var customerTokens: POCustomerTokensService!

    // MARK: - SPI

    /// Logger with application category.
    @_spi(PO)
    public private(set) var logger: POLogger!

    /// Images repository.
    @_spi(PO)
    public let images: POImagesRepository = UrlSessionImagesRepository(session: .shared)

    // MARK: - Private Nested Types

    private enum Constants {
        static let applicationLoggerCategory = "Application"
        static let serviceLoggerCategory = "Service"
        static let repositoryLoggerCategory = "Repository"
        static let connectorLoggerCategory = "Connector"
        static let bundleIdentifier = "com.processout.processout-ios"
    }

    // MARK: - Private Properties

    private var _configuration: POUnfairlyLocked<ProcessOutConfiguration>

    // MARK: - Private Methods

    @MainActor
    private init(configuration: ProcessOutConfiguration) {
        self._configuration = .init(wrappedValue: configuration)
        commonInit()
    }

    @MainActor
    private func commonInit() {
        let deviceMetadataProvider = Self.createDeviceMetadataProvider()
        let remoteLoggerDestination = createRemoteLoggerDestination(deviceMetadataProvider: deviceMetadataProvider)
        let serviceLogger = createLogger(
            for: Constants.serviceLoggerCategory,
            additionalDestinations: remoteLoggerDestination
        )
        logger = createLogger(
            for: Constants.applicationLoggerCategory,
            additionalDestinations: remoteLoggerDestination
        )
        let httpConnector = createConnector(deviceMetadataProvider: deviceMetadataProvider)
        let threeDSService = Self.create3DSService()
        initServices(httpConnector: httpConnector, threeDSService: threeDSService, logger: serviceLogger)
    }

    private func initServices(httpConnector: HttpConnector, threeDSService: ThreeDSService, logger: POLogger) {
        gatewayConfigurations = HttpGatewayConfigurationsRepository(
            connector: httpConnector
        )
        invoices = Self.createInvoicesService(
            httpConnector: httpConnector, threeDSService: threeDSService, logger: logger
        )
        alternativePayments = createAlternativePaymentsService()
        cards = Self.createCardsService(
            httpConnector: httpConnector, logger: logger
        )
        customerTokens = Self.createCustomerTokensService(
            httpConnector: httpConnector, threeDSService: threeDSService, logger: logger
        )
    }

    // MARK: -

    private static func createCardsService(httpConnector: HttpConnector, logger: POLogger) -> POCardsService {
        let contactMapper = DefaultPassKitContactMapper(logger: logger)
        let requestMapper = DefaultApplePayCardTokenizationRequestMapper(
            contactMapper: contactMapper, decoder: JSONDecoder(), logger: logger
        )
        let service = DefaultCardsService(
            repository: HttpCardsRepository(connector: httpConnector),
            applePayCardTokenizationRequestMapper: requestMapper
        )
        return service
    }

    private static func createInvoicesService(
        httpConnector: HttpConnector, threeDSService: ThreeDSService, logger: POLogger
    ) -> POInvoicesService {
        let repository = HttpInvoicesRepository(connector: httpConnector)
        return DefaultInvoicesService(repository: repository, threeDSService: threeDSService, logger: logger)
    }

    private static func createCustomerTokensService(
        httpConnector: HttpConnector, threeDSService: ThreeDSService, logger: POLogger
    ) -> POCustomerTokensService {
        let repository = HttpCustomerTokensRepository(connector: httpConnector)
        return DefaultCustomerTokensService(repository: repository, threeDSService: threeDSService, logger: logger)
    }

    private func createAlternativePaymentsService() -> POAlternativePaymentsService {
        let serviceConfiguration = { @Sendable [unowned self] () -> AlternativePaymentsServiceConfiguration in
            let configuration = self.configuration
            return .init(projectId: configuration.projectId, baseUrl: configuration.checkoutBaseUrl)
        }
        let webSession = DefaultWebAuthenticationSession()
        return DefaultAlternativePaymentsService(
            configuration: serviceConfiguration, webSession: webSession, logger: logger
        )
    }

    private static func create3DSService() -> DefaultThreeDSService {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        let encoder = JSONEncoder()
        encoder.dataEncodingStrategy = .base64
        encoder.keyEncodingStrategy = .useDefaultKeys
        let webSession = DefaultWebAuthenticationSession()
        return DefaultThreeDSService(decoder: decoder, encoder: encoder, webSession: webSession)
    }

    private func createConnector(
        deviceMetadataProvider: DeviceMetadataProvider, remoteLoggerDestination: LoggerDestination? = nil
    ) -> HttpConnector {
        let connectorConfiguration = { @Sendable [unowned self] in
            let configuration = self.configuration
            return HttpConnectorRequestMapperConfiguration(
                baseUrl: configuration.apiBaseUrl,
                projectId: configuration.projectId,
                privateKey: configuration.privateKey,
                sessionId: configuration.sessionId,
                version: ProcessOut.version
            )
        }
        let logger = createLogger(
            for: Constants.connectorLoggerCategory, additionalDestinations: remoteLoggerDestination
        )
        let connector = ProcessOutHttpConnectorBuilder()
            .with(configuration: connectorConfiguration)
            .with(logger: logger)
            .with(deviceMetadataProvider: deviceMetadataProvider)
            .build()
        return connector
    }

    private func createLogger(
        for category: String, additionalDestinations: LoggerDestination?...
    ) -> POLogger {
        var destinations: [LoggerDestination] = [
            SystemLoggerDestination(subsystem: Constants.bundleIdentifier)
        ]
        destinations.append(
            contentsOf: additionalDestinations.compactMap { $0 }
        )
        let minimumLevel = { @Sendable [unowned self] () -> LogLevel in
            configuration.isDebug ? .debug : .info
        }
        return POLogger(destinations: destinations, category: category, minimumLevel: minimumLevel)
    }

    private func createRemoteLoggerDestination(
        deviceMetadataProvider: DeviceMetadataProvider
    ) -> DefaultTelemetryService {
        let configuration = { @Sendable [unowned self] () -> TelemetryServiceConfiguration in
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
            connector: createConnector(deviceMetadataProvider: deviceMetadataProvider)
        )
        return DefaultTelemetryService(
            configuration: configuration, repository: repository, deviceMetadataProvider: deviceMetadataProvider
        )
    }

    @MainActor
    private static func createDeviceMetadataProvider() -> DeviceMetadataProvider {
        let keychain = Keychain(service: Constants.bundleIdentifier)
        return DefaultDeviceMetadataProvider(screen: .main, device: .current, bundle: .main, keychain: keychain)
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
    ///   - force: When set to `false` (the default) only the first invocation takes effect, all
    /// subsequent calls to this method are ignored. Pass `true` to allow existing shared instance
    /// reconfiguration (if any).
    @MainActor
    public static func configure(configuration: ProcessOutConfiguration, force: Bool = false) {
        MainActor.preconditionIsolated("Shared instance must be configured from main thread.")
        if isConfigured {
            if force {
                shared._configuration.withLock { $0 = configuration }
                shared.logger.debug("Did change ProcessOut configuration")
            } else {
                shared.logger.debug("ProcessOut can be configured only once, ignored")
            }
        } else {
            _shared.withLock { instance in
                instance = ProcessOut(configuration: configuration)
            }
            shared.logger.debug("Did complete ProcessOut configuration")
        }
    }

    // MARK: - Private Properties

    private static let _shared = POUnfairlyLocked<ProcessOut?>(wrappedValue: nil)
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
