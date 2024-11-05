//
//  POCheckout3DSService.swift
//  ProcessOutCheckout3DS
//
//  Created by Andrii Vysotskyi on 28.02.2023.
//

@_spi(PO) import ProcessOut
import Checkout3DS

/// 3DS2 service implementation that is based on Checkout3DS.
@MainActor
public final class POCheckout3DSService: PO3DS2Service {

    /// Creates service instance.
    public nonisolated init(delegate: POCheckout3DSServiceDelegate? = nil, environment: Environment = .production) {
        self.errorMapper = DefaultAuthenticationErrorMapper()
        self.configurationMapper = DefaultConfigurationMapper()
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
                throw POFailure(code: .cancelled)
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
                throw POFailure(code: .generic(.mobile))
            }
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
        service?.cleanUp()
    }

    // MARK: - Private Properties

    private let errorMapper: AuthenticationErrorMapper
    private let configurationMapper: ConfigurationMapper
    private nonisolated(unsafe) var environment: Checkout3DS.Environment
    private let delegate: POCheckout3DSServiceDelegate?
    private var service: ThreeDS2Service?

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
        return POFailure(code: .generic(.mobile), underlyingError: error)
    }
}
