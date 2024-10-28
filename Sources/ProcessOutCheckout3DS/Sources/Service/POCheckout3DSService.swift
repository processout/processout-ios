//
//  POCheckout3DSService.swift
//  ProcessOutCheckout3DS
//
//  Created by Andrii Vysotskyi on 28.02.2023.
//

@_spi(PO) import ProcessOut
import Checkout3DS

public actor POCheckout3DSService: PO3DS2Service {

    // MARK: - PO3DS2Service

    public func authenticationRequestParameters(
        configuration: PO3DS2Configuration
    ) async throws -> PO3DS2AuthenticationRequestParameters {
        try await waitForSemaphoreUnlessCancelled()
        defer {
            semaphore.signal()
        }
        invalidate()
        await delegate?.checkout3DSService(self, willCreateAuthenticationRequestParametersWith: configuration)
        do {
            let service = try Standalone3DSService.initialize(
                with: await serviceConfiguration(with: configuration), environment: environment
            )
            self.service = service
            let warnings = service.getWarnings()
            guard await delegate?.checkout3DSService(self, shouldContinueWith: warnings) ?? true else {
                throw POFailure(code: .cancelled)
            }
            let authenticationRequest = authenticationRequest(
                with: try await service.createTransaction().getAuthenticationRequestParameters()
            )
            await delegate?.checkout3DSService(
                self, didCreateAuthenticationRequestParameters: .success(authenticationRequest)
            )
            return authenticationRequest
        } catch {
            invalidate()
            let failure = failure(with: error)
            await delegate?.checkout3DSService(self, didCreateAuthenticationRequestParameters: .failure(failure))
            throw failure
        }
    }

    public func performChallenge(with parameters: PO3DS2ChallengeParameters) async throws -> PO3DS2ChallengeResult {
        try await waitForSemaphoreUnlessCancelled()
        defer {
            invalidate()
            semaphore.signal()
        }
        await delegate?.checkout3DSService(self, willPerformChallengeWith: parameters)
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
    private let semaphore: POAsyncSemaphore
    private let environment: Checkout3DS.Environment

    private var service: ThreeDS2Service?
    private weak var delegate: POCheckout3DSServiceDelegate?

    // MARK: -

    init(
        errorMapper: AuthenticationErrorMapper,
        configurationMapper: ConfigurationMapper,
        delegate: POCheckout3DSServiceDelegate?,
        environment: Checkout3DS.Environment
    ) {
        self.errorMapper = errorMapper
        self.configurationMapper = configurationMapper
        self.delegate = delegate
        self.environment = environment
        semaphore = .init(value: 1)
    }

    deinit {
        service?.cleanUp()
    }

    // MARK: - Utils

    private func invalidate() {
        service?.cleanUp()
        service = nil
    }

    private func waitForSemaphoreUnlessCancelled() async throws(POFailure) {
        do {
            try await semaphore.waitUnlessCancelled()
        } catch {
            throw POFailure(message: "3DS session was cancelled.", code: .cancelled)
        }
    }

    // MARK: - Mapping

    private func serviceConfiguration(
        with configuration: PO3DS2Configuration
    ) async throws -> ThreeDS2ServiceConfiguration {
        let configParameters = try configurationMapper.convert(configuration: configuration)
        let serviceConfiguration = await delegate?.checkout3DSService(self, configurationWith: configParameters)
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

extension POCheckout3DSService {

    /// Creates service instance.
    public init(delegate: POCheckout3DSServiceDelegate? = nil, environment: Environment = .production) {
        self.init(
            errorMapper: DefaultAuthenticationErrorMapper(),
            configurationMapper: DefaultConfigurationMapper(),
            delegate: delegate,
            environment: environment
        )
    }
}
