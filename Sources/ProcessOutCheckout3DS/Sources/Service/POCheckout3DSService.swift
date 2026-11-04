//
//  POCheckout3DSService.swift
//  ProcessOutCheckout3DS
//
//  Created by Andrii Vysotskyi on 28.02.2023.
//

@_spi(PO) import ProcessOut
import Checkout3DS

/// 3DS2 service implementation that is based on Checkout3DS.
///
/// 3DS flow is strictly sequential: an authentication, optionally followed by a challenge, and
/// `clean()` at the end. The service does not serialize concurrent calls. Overlapping operations
/// are considered a developer error and are rejected.
@MainActor
public final class POCheckout3DSService: PO3DS2Service {

    /// Creates service instance.
    public nonisolated convenience init(
        delegate: POCheckout3DSServiceDelegate? = nil, environment: Environment = .production
    ) {
        self.init(
            delegate: delegate,
            environment: environment,
            eventEmitter: ProcessOut.shared.eventEmitter,
            logger: ProcessOut.shared.logger
        )
    }

    // MARK: - PO3DS2Service

    public func authenticationRequestParameters(
        configuration: PO3DS2Configuration
    ) async throws -> PO3DS2AuthenticationRequestParameters {
        delegate?.checkout3DSService(self, willCreateAuthenticationRequestParametersWith: configuration)
        do {
            if Task.isCancelled {
                throw POFailure(message: "Authentication was cancelled.", code: .Mobile.cancelled)
            }
            switch state {
            case .idle:
                break
            case .ready:
                throw POFailure(
                    message: "Previous transaction was not cleaned, call clean() first.", code: .Mobile.generic
                )
            case .authenticating, .challenging, .cleaning:
                throw POFailure(message: "Another operation is already in progress.", code: .Mobile.generic)
            }
            state = .authenticating
            let (context, parameters): (TransactionContext, PO3DS2AuthenticationRequestParameters)
            do {
                (context, parameters) = try await createTransaction(configuration: configuration)
            } catch {
                state = .idle
                throw error
            }
            state = .ready(context)
            delegate?.checkout3DSService(self, didCreateAuthenticationRequestParameters: .success(parameters))
            return parameters
        } catch {
            let failure = failure(with: error)
            delegate?.checkout3DSService(self, didCreateAuthenticationRequestParameters: .failure(failure))
            throw failure
        }
    }

    public func performChallenge(with parameters: PO3DS2ChallengeParameters) async throws -> PO3DS2ChallengeResult {
        delegate?.checkout3DSService(self, willPerformChallengeWith: parameters)
        do {
            if Task.isCancelled {
                throw POFailure(message: "Challenge was cancelled.", code: .Mobile.cancelled)
            }
            guard case .ready(let context) = state,
                  context.transactionId == parameters.threeDSServerTransactionId else {
                throw POFailure(message: "Unable to resolve current transaction.", code: .Mobile.generic)
            }
            state = .challenging(context)
            defer {
                state = .ready(context)
            }
            let challengeResult = try await performChallenge(with: parameters, in: context)
            delegate?.checkout3DSService(self, didPerformChallenge: .success(challengeResult))
            return challengeResult
        } catch {
            let failure = failure(with: error)
            delegate?.checkout3DSService(self, didPerformChallenge: .failure(failure))
            throw failure
        }
    }

    public func clean() async {
        switch state {
        case .idle:
            break
        case .ready(let context):
            state = .cleaning
            tearDown(service: context.service)
            deepLinkObservation = nil
            state = .idle
        case .authenticating, .challenging, .cleaning:
            logger.warn("Ignoring clean() while another operation is in progress.")
        }
    }

    // MARK: -

    typealias ServiceProvider = @MainActor (ThreeDS2ServiceConfiguration, Environment) throws -> ThreeDS2Service

    nonisolated init(
        delegate: POCheckout3DSServiceDelegate? = nil,
        environment: Environment = .production,
        eventEmitter: POEventEmitter,
        logger: POLogger,
        serviceProvider: @escaping ServiceProvider = { try Standalone3DSService.initialize(with: $0, environment: $1) }
    ) {
        self.errorMapper = DefaultAuthenticationErrorMapper()
        self.configurationMapper = DefaultConfigurationMapper()
        self.eventEmitter = eventEmitter
        self.logger = logger
        self.delegate = delegate
        self.environment = environment
        self.serviceProvider = serviceProvider
    }

    // MARK: - Private Nested Types

    private enum State {

        /// No transaction. The only state from which authentication may start.
        case idle

        /// Authentication request parameters are being created.
        case authenticating

        /// Transaction exists and may be challenged or cleaned.
        case ready(TransactionContext)

        /// Challenge is being performed on the transaction.
        case challenging(TransactionContext)

        /// Transaction is being closed and SDK resources are being released.
        case cleaning
    }

    private struct TransactionContext {
        let service: ThreeDS2Service, transaction: Transaction, transactionId: String
    }

    // MARK: - Private Properties

    private let errorMapper: AuthenticationErrorMapper
    private let configurationMapper: ConfigurationMapper
    private let eventEmitter: POEventEmitter
    private let logger: POLogger

    private let environment: Checkout3DS.Environment
    private let delegate: POCheckout3DSServiceDelegate?
    private let serviceProvider: ServiceProvider

    private var state: State = .idle
    private var deepLinkObservation: AnyObject?

    // MARK: - Authentication

    /// Initializes the SDK and creates a transaction. Resources created before a failure are
    /// released here, so a failed authentication leaves nothing behind to clean.
    ///
    /// - NOTE: Transaction must be retained and reused for the challenge. Checkout's
    /// `createTransaction()` closes the current transaction and creates a new one with fresh
    /// SDK transaction ID and ephemeral keys, which would not match authentication request.
    private func createTransaction(
        configuration: PO3DS2Configuration
    ) async throws -> (TransactionContext, PO3DS2AuthenticationRequestParameters) {
        var initializedService: ThreeDS2Service?
        do {
            let service = try serviceProvider(await serviceConfiguration(with: configuration), environment)
            initializedService = service
            if let delegate, await !delegate.checkout3DSService(self, shouldContinueWith: await service.warnings) {
                throw POFailure(code: .Mobile.cancelled)
            }
            let transaction = service.createTransaction()
            let parameters = authenticationRequest(with: try await transaction.getAuthenticationRequestParameters())
            let context = TransactionContext(
                service: service, transaction: transaction, transactionId: configuration.directoryServerTransactionId
            )
            return (context, parameters)
        } catch {
            tearDown(service: initializedService)
            throw error
        }
    }

    // MARK: - Challenge

    private func performChallenge(
        with parameters: PO3DS2ChallengeParameters, in context: TransactionContext
    ) async throws -> PO3DS2ChallengeResult {
        observeDeepLinks()
        let authenticationResult = try await context.transaction.doChallenge(
            challengeParameters: challengeParameters(with: parameters)
        )
        return PO3DS2ChallengeResult(transactionStatus: authenticationResult.transactionStatus ?? "N")
    }

    // MARK: - Clean

    /// - NOTE: Checkout's `cleanUp()` closes the current transaction, so transaction is not closed explicitly.
    private func tearDown(service: ThreeDS2Service?) {
        service?.cleanUp()
    }

    // MARK: - Mapping

    private func serviceConfiguration(
        with configuration: PO3DS2Configuration
    ) async throws -> ThreeDS2ServiceConfiguration {
        let configParameters = try configurationMapper.convert(configuration: configuration)
        let serviceConfiguration = delegate?.checkout3DSService(self, configurationWith: configParameters)
        return serviceConfiguration ?? .init(configParameters: configParameters)
    }

    private func authenticationRequest(
        with request: AuthenticationRequestParameters
    ) -> PO3DS2AuthenticationRequestParameters {
        PO3DS2AuthenticationRequestParameters(
            deviceData: request.deviceData,
            sdkAppId: request.sdkAppID,
            sdkEphemeralPublicKey: request.sdkEphemeralPublicKey,
            sdkReferenceNumber: request.sdkReferenceNumber,
            sdkTransactionId: request.sdkTransactionID
        )
    }

    private func challengeParameters(with parameters: PO3DS2ChallengeParameters) -> ChallengeParameters {
        ChallengeParameters(
            threeDSServerTransactionID: parameters.threeDSServerTransactionId,
            acsTransactionID: parameters.acsTransactionId,
            acsRefNumber: parameters.acsReferenceNumber,
            acsSignedContent: parameters.acsSignedContent
        )
    }

    private func failure(with error: Error) -> POFailure {
        if let failure = error as? POFailure {
            return failure
        }
        if let error = error as? AuthenticationError {
            return errorMapper.convert(error: error)
        }
        return POFailure(code: .Mobile.generic, underlyingError: error)
    }

    private func observeDeepLinks() {
        deepLinkObservation = eventEmitter.on(PODeepLinkReceivedEvent.self) { event in
            Checkout3DSService.handleAppURL(url: event.url)
        }
    }
}
