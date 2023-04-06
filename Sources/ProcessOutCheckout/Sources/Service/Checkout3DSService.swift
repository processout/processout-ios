//
//  Checkout3DSService.swift
//  ProcessOutCheckout
//
//  Created by Andrii Vysotskyi on 28.02.2023.
//

import ProcessOut
import Checkout3DS

final class Checkout3DSService: PO3DSServiceType {

    init(
        errorMapper: AuthenticationErrorMapperType,
        configurationMapper: ConfigurationMapperType,
        delegate: POCheckout3DSServiceDelegate
    ) {
        self.errorMapper = errorMapper
        self.configurationMapper = configurationMapper
        self.delegate = delegate
        queue = DispatchQueue.global()
        state = .idle
    }

    deinit {
        clean()
    }

    // MARK: - PO3DSServiceType

    func authenticationRequest(
        configuration: PO3DS2Configuration,
        completion: @escaping (Result<PO3DS2AuthenticationRequest, POFailure>) -> Void
    ) {
        switch state {
        case .idle, .fingerprinted:
            clean()
        default:
            let failure = POFailure(code: .generic(.mobile))
            completion(.failure(failure))
            return
        }
        let configurationParameters = configurationMapper.convert(configuration: configuration)
        let configuration = delegate.configuration(with: configurationParameters)
        do {
            let service = try Standalone3DSService.initialize(with: configuration, environment: .sandbox)
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
                                    self.setIdleStateUnchecked()
                                }
                                completion(mappedResult)
                            }
                        } else {
                            self.setIdleStateUnchecked()
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
        let parameters = convertToChallengeParameters(data: challenge)
        context.transaction.doChallenge(challengeParameters: parameters) { [unowned self, errorMapper] result in
            self.setIdleStateUnchecked()
            completion(result.map(extractStatus(challengeResult:)).mapError(errorMapper.convert))
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
    private let configurationMapper: ConfigurationMapperType
    private let queue: DispatchQueue
    private let delegate: POCheckout3DSServiceDelegate

    private var state: State

    // MARK: - Private Methods

    private func setIdleStateUnchecked() {
        clean()
        state = .idle
    }

    private func clean() {
        let currentContext: Checkout3DSServiceState.Context
        switch state {
        case let .fingerprinting(context), let .fingerprinted(context), let .challenging(context):
            currentContext = context
        default:
            return
        }
        currentContext.transaction.close()
        currentContext.service.cleanUp()
    }

    // MARK: - Utils

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

    private func extractStatus(challengeResult: ChallengeResult) -> Bool {
        challengeResult.transactionStatus.uppercased() == "Y"
    }
}
