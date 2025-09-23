//
//  POCheckout3DSService.swift
//  ProcessOutCheckout3DS
//
//  Created by Andrii Vysotskyi on 28.02.2023.
//

import ProcessOutCore
import Checkout3DS

/// 3DS2 service implementation that is based on Checkout3DS.
@MainActor
public final class POCheckout3DSService: PO3DS2Service {

    /// Creates service instance.
    @_disfavoredOverload
    public nonisolated init(delegate: POCheckout3DSServiceDelegate? = nil, environment: Environment = .production) {
        self.errorMapper = DefaultAuthenticationErrorMapper()
        self.configurationMapper = DefaultConfigurationMapper()
        self.eventEmitter = nil
        self.delegate = delegate
        self.environment = environment
    }

    @_disfavoredOverload
    package nonisolated init(
        delegate: POCheckout3DSServiceDelegate? = nil,
        environment: Environment = .production,
        eventEmitter: POEventEmitter
    ) {
        self.errorMapper = DefaultAuthenticationErrorMapper()
        self.configurationMapper = DefaultConfigurationMapper()
        self.eventEmitter = eventEmitter
        self.delegate = delegate
        self.environment = environment
    }

    // MARK: - PO3DS2Service

    public func authenticationRequestParameters(
        configuration: PO3DS2Configuration
    ) async throws -> PO3DS2AuthenticationRequestParameters {
        delegate?.checkout3DSService(self, willCreateAuthenticationRequestParametersWith: configuration)
        do {
            let service = try Standalone3DSService.initialize(
                with: await serviceConfiguration(with: configuration), environment: environment
            )
            self.service = service
            guard await delegate?.checkout3DSService(self, shouldContinueWith: await service.warnings) ?? true else {
                throw POFailure(code: .Mobile.cancelled)
            }
            let authenticationRequest = authenticationRequest(
                with: try await service.createTransaction().getAuthenticationRequestParameters()
            )
            delegate?.checkout3DSService(
                self, didCreateAuthenticationRequestParameters: .success(authenticationRequest)
            )
            return authenticationRequest
        } catch {
            let failure = failure(with: error)
            delegate?.checkout3DSService(self, didCreateAuthenticationRequestParameters: .failure(failure))
            throw failure
        }
    }

    public func performChallenge(with parameters: PO3DS2ChallengeParameters) async throws -> PO3DS2ChallengeResult {
        delegate?.checkout3DSService(self, willPerformChallengeWith: parameters)
        do {
            guard let transaction = service?.createTransaction() else {
                throw POFailure(code: .Mobile.generic)
            }
            observeDeepLinks()
            let authenticationResult = try await transaction.doChallenge(
                challengeParameters: challengeParameters(with: parameters)
            )
            let challengeResult = PO3DS2ChallengeResult(
                transactionStatus: authenticationResult.transactionStatus ?? "N"
            )
            delegate?.checkout3DSService(self, didPerformChallenge: .success(challengeResult))
            return challengeResult
        } catch {
            let failure = failure(with: error)
            delegate?.checkout3DSService(self, didPerformChallenge: .failure(failure))
            throw failure
        }
    }

    public func clean() async {
        deepLinkObservation = nil
        service?.cleanUp()
        service = nil
    }

    // MARK: - Private Properties

    private let errorMapper: AuthenticationErrorMapper
    private let configurationMapper: ConfigurationMapper
    private let eventEmitter: POEventEmitter?

    private let environment: Checkout3DS.Environment
    private let delegate: POCheckout3DSServiceDelegate?

    private var service: ThreeDS2Service?
    private var deepLinkObservation: AnyObject?

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
        deepLinkObservation = eventEmitter?.on(PODeepLinkReceivedEvent.self) { event in
            Checkout3DSService.handleAppURL(url: event.url)
        }
    }
}
