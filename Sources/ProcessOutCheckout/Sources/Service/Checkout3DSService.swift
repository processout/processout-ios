//
//  Checkout3DSService.swift
//  ProcessOutCheckout
//
//  Created by Andrii Vysotskyi on 28.02.2023.
//

@_spi(PO) import ProcessOut
import Checkout3DS

final class Checkout3DSService: PO3DSServiceType {

    init(errorMapper: AuthenticationErrorMapperType, delegate: POCheckout3DSServiceDelegate) {
        self.errorMapper = errorMapper
        self.delegate = delegate
        queue = DispatchQueue.global()
        state = .idle
    }

    deinit {
        setIdleState()
    }

    // MARK: - PO3DSServiceType

    func authenticationRequest(
        configuration: PO3DS2Configuration,
        completion: @escaping (Result<PO3DS2AuthenticationRequest, POFailure>) -> Void
    ) {
        switch state {
        case .idle, .fingerprinted:
            break
        default:
            let failure = POFailure(code: .generic(.mobile))
            completion(.failure(failure))
            return
        }
        let configurationParameters = convertToConfigParameters(configuration: configuration)
        let configuration = delegate.willFingerprintDevice(parameters: configurationParameters)
        do {
            let service = try Standalone3DSService.initialize(with: configuration)
            let context = State.Context(service: service, transaction: service.createTransaction())
            state = .fingerprinting(context)
            queue.async { [unowned self, errorMapper] in
                let warnings = service.getWarnings()
                DispatchQueue.main.async {
                    self.delegate.shouldContinue(with: warnings) { shouldContinue in
                        assert(Thread.isMainThread, "Completion must be called on main thread.")
                        if shouldContinue {
                            context.transaction.getAuthenticationRequestParameters { result in
                                let mappedResult = result
                                    .mapError(errorMapper.convert)
                                    .map(self.convertToAuthenticationRequest)
                                switch mappedResult {
                                case .success:
                                    self.state = .fingerprinted(context)
                                case .failure:
                                    self.setIdleState()
                                }
                                completion(mappedResult)
                            }
                        } else {
                            self.setIdleState()
                            completion(.failure(POFailure(code: .cancelled)))
                        }
                    }
                }
            }
        } catch let error as AuthenticationError {
            completion(.failure(errorMapper.convert(error: error)))
        } catch {
            let failure = POFailure(code: .generic(.mobile), underlyingError: error)
            completion(.failure(failure))
        }
    }

    func handle(challenge: PO3DS2Challenge, completion: @escaping (Result<Bool, POFailure>) -> Void) {
        guard case let .fingerprinted(context) = state else {
            let failure = POFailure(code: .generic(.mobile))
            completion(.failure(failure))
            return
        }
        state = .challenging(context)
        let challengeParameters = convertToChallengeParameters(data: challenge)
        context.transaction.doChallenge(challengeParameters: challengeParameters) { [weak self, errorMapper] result in
            self?.setIdleState()
            completion(result.mapError(errorMapper.convert))
        }
    }

    func handle(redirect: PO3DSRedirect, completion: @escaping (Result<String, POFailure>) -> Void) {
        // Redirection is simply forwarded to delegate without additional validations.
        delegate.handle(redirect: redirect, completion: completion)
    }

    // MARK: - Private Nested Types

    private typealias State = Checkout3DSServiceState

    // MARK: - Private Properties

    private let errorMapper: AuthenticationErrorMapperType
    private let queue: DispatchQueue
    private let delegate: POCheckout3DSServiceDelegate

    private var state: State

    // MARK: - Private Methods

    private func setIdleState() {
        switch state {
        case .idle:
            return
        case let .fingerprinting(context), let .fingerprinted(context), let .challenging(context):
            context.transaction.close()
            context.service.cleanUp()
        }
        state = .idle
    }

    // MARK: - Utils

    private func convertToConfigParameters(
        configuration: PO3DS2Configuration
    ) -> ThreeDS2ServiceConfiguration.ConfigParameters {
        let directoryServerData = ThreeDS2ServiceConfiguration.DirectoryServerData(
            directoryServerID: configuration.directoryServerId,
            directoryServerPublicKey: configuration.directoryServerPublicKey,
            directoryServerRootCertificate: configuration.directoryServerRootCertificate
        )
        let configParameters = ThreeDS2ServiceConfiguration.ConfigParameters(
            directoryServerData: directoryServerData,
            messageVersion: configuration.messageVersion,
            scheme: ""
        )
        return configParameters
    }

    private func convertToAuthenticationRequest(
        request: AuthenticationRequestParameters
    ) -> PO3DS2AuthenticationRequest {
        let authenticationRequest = PO3DS2AuthenticationRequest(
            deviceData: request.deviceData,
            sdkAppId: request.sdkAppID,
            sdkEphemeralPublicKey: request.sdkEphemeralPublicKey,
            sdkReferenceNumber: request.sdkReferenceNumber,
            sdkTransactionId: request.sdkTransactionID
        )
        return authenticationRequest
    }

    private func convertToChallengeParameters(data: PO3DS2Challenge) -> ChallengeParameters {
        let challengeParameters = ChallengeParameters(
            threeDSServerTransactionID: data.threeDSServerTransactionId,
            acsTransactionID: data.acsTransactionId,
            acsRefNumber: data.acsReferenceNumber,
            acsSignedContent: data.acsSignedContent
        )
        return challengeParameters
    }
}
