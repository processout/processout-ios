//
//  Checkout3DSService.swift
//  ProcessOutCheckout3DS
//
//  Created by Andrii Vysotskyi on 28.02.2023.
//

import ProcessOut
import Checkout3DS

final class Checkout3DSService: PO3DS2Service {

    init(
        errorMapper: AuthenticationErrorMapper,
        configurationMapper: ConfigurationMapper,
        delegate: POCheckout3DSServiceDelegate,
        environment: Checkout3DS.Environment
    ) {
        self.errorMapper = errorMapper
        self.configurationMapper = configurationMapper
        self.delegate = delegate
        self.environment = environment
        queue = DispatchQueue.global()
        state = .idle
    }

    deinit {
        clean()
    }

    // MARK: - PO3DSService

    // swiftlint:disable:next function_body_length
    func authenticationRequest(
        configuration: PO3DS2Configuration,
        completion: @escaping (Result<PO3DS2AuthenticationRequest, POFailure>) -> Void
    ) {
        delegate.willCreateAuthenticationRequest(configuration: configuration)
        switch state {
        case .idle, .fingerprinted:
            clean()
        default:
            let failure = POFailure(code: .generic(.mobile))
            delegate.didCreateAuthenticationRequest(result: .failure(failure))
            completion(.failure(failure))
            return
        }
        let configurationParameters = configurationMapper.convert(configuration: configuration)
        let configuration = delegate.configuration(with: configurationParameters)
        do {
            let service = try Standalone3DSService.initialize(with: configuration, environment: environment)
            let context = State.Context(service: service, transaction: service.createTransaction())
            state = .fingerprinting(context)
            queue.async { [unowned self, errorMapper] in
                let warnings = service.getWarnings()
                DispatchQueue.main.async {
                    self.delegate.shouldContinue(with: warnings) { shouldContinue in
                        assert(Thread.isMainThread, "Completion must be called on main thread.")
                        if shouldContinue {
                            context.transaction.getAuthenticationRequestParameters { [unowned self] result in
                                let mappedResult = result
                                    .mapError(errorMapper.convert)
                                    .map(self.convertToAuthenticationRequest)
                                switch mappedResult {
                                case .success:
                                    self.state = .fingerprinted(context)
                                case .failure:
                                    self.setIdleStateUnchecked()
                                }
                                self.delegate.didCreateAuthenticationRequest(result: mappedResult)
                                completion(mappedResult)
                            }
                        } else {
                            self.setIdleStateUnchecked()
                            let failure = POFailure(code: .cancelled)
                            self.delegate.didCreateAuthenticationRequest(result: .failure(failure))
                            completion(.failure(failure))
                        }
                    }
                }
            }
        } catch let error as AuthenticationError {
            let failure = errorMapper.convert(error: error)
            delegate.didCreateAuthenticationRequest(result: .failure(failure))
            completion(.failure(failure))
        } catch {
            let failure = POFailure(code: .generic(.mobile), underlyingError: error)
            delegate.didCreateAuthenticationRequest(result: .failure(failure))
            completion(.failure(failure))
        }
    }

    func handle(challenge: PO3DS2Challenge, completion: @escaping (Result<Bool, POFailure>) -> Void) {
        delegate.willHandle(challenge: challenge)
        guard case let .fingerprinted(context) = state else {
            let failure = POFailure(code: .generic(.mobile))
            delegate.didHandle3DS2Challenge(result: .failure(failure))
            completion(.failure(failure))
            return
        }
        state = .challenging(context)
        let parameters = convertToChallengeParameters(data: challenge)
        context.transaction.doChallenge(challengeParameters: parameters) { [unowned self, errorMapper] result in
            self.setIdleStateUnchecked()
            let mappedResult = result.map(extractStatus(authenticationResult:)).mapError(errorMapper.convert)
            delegate.didHandle3DS2Challenge(result: mappedResult)
            completion(mappedResult)
        }
    }

    // MARK: - Private Nested Types

    private typealias State = Checkout3DSServiceState

    // MARK: - Private Properties

    private let errorMapper: AuthenticationErrorMapper
    private let configurationMapper: ConfigurationMapper
    private let queue: DispatchQueue
    private let delegate: POCheckout3DSServiceDelegate
    private let environment: Checkout3DS.Environment

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

    private func extractStatus(authenticationResult: AuthenticationResult) -> Bool {
        authenticationResult.transactionStatus?.uppercased() == "Y"
    }
}
