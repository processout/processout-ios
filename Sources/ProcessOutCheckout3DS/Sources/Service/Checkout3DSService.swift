//
//  POCheckout3DSService.swift
//  ProcessOutCheckout3DS
//
//  Created by Andrii Vysotskyi on 28.02.2023.
//

import ProcessOut
import Checkout3DS

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

    public func authenticationRequest(configuration: PO3DS2Configuration) async throws -> PO3DS2AuthenticationRequest {
        invalidate()
        do {
            await delegate?.willCreateAuthenticationRequest(configuration: configuration)
            let service = try Standalone3DSService.initialize(
                with: await serviceConfiguration(with: configuration), environment: environment
            )
            self.service = service
            guard await delegate?.shouldContinue(with: service.getWarnings()) ?? true else {
                throw POFailure(code: .cancelled)
            }
            let authenticationRequest = authenticationRequest(
                with: try await service.createTransaction().getAuthenticationRequestParameters()
            )
            await delegate?.didCreateAuthenticationRequest(result: .success(authenticationRequest))
            return authenticationRequest
        } catch {
            invalidate()
            let failure = failure(with: error)
            await delegate?.didCreateAuthenticationRequest(result: .failure(failure))
            throw failure
        }
    }

    public func handle(challenge: PO3DS2Challenge) async throws -> Bool {
        defer {
            invalidate()
        }
        do {
            await delegate?.willHandle(challenge: challenge)
            guard let transaction = service?.createTransaction() else {
                throw POFailure(code: .generic(.mobile))
            }
            let authenticationStatus = try await isSuccess(
                authenticationResult: transaction.doChallenge(challengeParameters: challengeParameters(with: challenge))
            )
            await delegate?.didHandle3DS2Challenge(result: .success(authenticationStatus))
            return authenticationStatus
        } catch {
            let failure = failure(with: error)
            await delegate?.didHandle3DS2Challenge(result: .failure(failure))
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
        guard let delegate else {
            return ThreeDS2ServiceConfiguration(configParameters: configParameters)
        }
        return await delegate.configuration(with: configParameters)
    }

    private func authenticationRequest(with request: AuthenticationRequestParameters) -> PO3DS2AuthenticationRequest {
        PO3DS2AuthenticationRequest(
            deviceData: request.deviceData,
            sdkAppId: request.sdkAppID,
            sdkEphemeralPublicKey: request.sdkEphemeralPublicKey,
            sdkReferenceNumber: request.sdkReferenceNumber,
            sdkTransactionId: request.sdkTransactionID
        )
    }

    private func challengeParameters(with challenge: PO3DS2Challenge) -> ChallengeParameters {
        ChallengeParameters(
            threeDSServerTransactionID: challenge.threeDSServerTransactionId,
            acsTransactionID: challenge.acsTransactionId,
            acsRefNumber: challenge.acsReferenceNumber,
            acsSignedContent: challenge.acsSignedContent
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

    private func isSuccess(authenticationResult: AuthenticationResult) -> Bool {
        authenticationResult.transactionStatus?.uppercased() == "Y"
    }
}
