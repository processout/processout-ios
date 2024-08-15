//
//  POCheckout3DSService.swift
//  ProcessOutCheckout3DS
//
//  Created by Andrii Vysotskyi on 28.02.2023.
//

import ProcessOut
import Checkout3DS

/// Adaptor wraps Checkout's `Standalone3DSService` service so it could be used with `ProcessOut` APIs
/// where instance of `PO3DSService` is expected.
public actor POCheckout3DSService: PO3DSService, Sendable {

    public init(delegate: POCheckout3DSServiceDelegate? = nil, environment: Environment = .production) {
        errorMapper = DefaultAuthenticationErrorMapper()
        configurationMapper = DefaultConfigurationMapper()
        self.delegate = delegate
        self.environment = environment
    }

    deinit {
        service?.cleanUp()
    }

    /// Service's delegate.
    public weak var delegate: POCheckout3DSServiceDelegate?

    // MARK: - PO3DSService

    public func authenticationRequestParameters(
        configuration: PO3DS2Configuration
    ) async throws -> PO3DS2AuthenticationRequestParameters {
        invalidate()
        do {
            let service = try Standalone3DSService.initialize(
                with: await serviceConfiguration(with: configuration), environment: environment
            )
            self.service = service
            guard await delegate?.checkout3DSService(self, shouldContinueWith: service.getWarnings()) ?? true else {
                throw POFailure(code: .cancelled)
            }
            let authenticationRequest = authenticationRequest(
                with: try await service.createTransaction().getAuthenticationRequestParameters()
            )
            await delegate?.checkout3DSService(self, didCreateFingerprintWith: .success(authenticationRequest))
            return authenticationRequest
        } catch {
            invalidate()
            let failure = failure(with: error)
            await delegate?.checkout3DSService(self, didCreateFingerprintWith: .failure(failure))
            throw failure
        }
    }

    public func performChallenge(with parameters: PO3DS2ChallengeParameters) async throws -> PO3DS2ChallengeResult {
        defer {
            invalidate()
        }
        do {
            await delegate?.checkout3DSService(self, willPerformChallengeWith: parameters)
            guard let transaction = service?.createTransaction() else {
                throw POFailure(code: .generic(.mobile))
            }
            let authenticationResult = try await transaction.doChallenge(
                challengeParameters: challengeParameters(with: parameters)
            )
            let challengeResult = PO3DS2ChallengeResult(
                transactionStatus: authenticationResult.transactionStatus ?? "N"
            )
            await delegate?.checkout3DSService(self, didPerformChallenge: .success(challengeResult))
            return challengeResult
        } catch {
            let failure = failure(with: error)
            await delegate?.checkout3DSService(self, didPerformChallenge: .failure(failure))
            throw failure
        }
    }

    // MARK: - Private Properties

    private let errorMapper: AuthenticationErrorMapper
    private let configurationMapper: ConfigurationMapper
    private let environment: Checkout3DS.Environment

    private var service: ThreeDS2Service?

    // MARK: - Private Methods

    private func invalidate() {
        service?.cleanUp()
        service = nil
    }

    // MARK: - Utils

    private func serviceConfiguration(with configuration: PO3DS2Configuration) async -> ThreeDS2ServiceConfiguration {
        let configParameters = configurationMapper.convert(configuration: configuration)
        var serviceConfiguration = ThreeDS2ServiceConfiguration(configParameters: configParameters)
        await delegate?.checkout3DSService(self, willCreateAuthenticationRequestParametersWith: &serviceConfiguration)
        return serviceConfiguration
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
        return POFailure(code: .generic(.mobile), underlyingError: error)
    }
}
