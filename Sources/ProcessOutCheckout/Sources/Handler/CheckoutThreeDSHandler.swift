//
//  CheckoutThreeDSHandler.swift
//  ProcessOutCheckout
//
//  Created by Andrii Vysotskyi on 28.02.2023.
//

// swiftlint:disable todo

@_spi(PO) import ProcessOut
import Checkout3DS

final class CheckoutThreeDSHandler: PO3DSHandlerType {

    init(
        errorMapper: AuthenticationErrorMapperType,
        authenticationRequestMapper: AuthenticationRequestMapperType,
        delegate: POCheckoutThreeDSHandlerDelegate
    ) {
        self.errorMapper = errorMapper
        self.authenticationRequestMapper = authenticationRequestMapper
        self.delegate = delegate
        queue = DispatchQueue.global()
        state = .idle
    }

    deinit {
        setIdleState()
    }

    // MARK: - PO3DSHandlerType

    func authenticationRequest(
        data: PODirectoryServerData, completion: @escaping (Result<PO3DSAuthenticationRequest, POFailure>) -> Void
    ) {
        switch state {
        case .idle, .fingerprinted:
            break
        default:
            let failure = POFailure(code: .generic(.mobile))
            completion(.failure(failure))
            return
        }
        let configurationParameters = convertToConfigParameters(data: data)
        let configuration = delegate.willFingerprintDevice(parameters: configurationParameters)
        do {
            let service = try Standalone3DSService.initialize(with: configuration)
            let context = State.Context(service: service, transaction: service.createTransaction())
            state = .fingerprinting(context)
            queue.async { [weak self, errorMapper, authenticationRequestMapper] in
                let warnings = service.getWarnings()
                DispatchQueue.main.async {
                    self?.delegate.shouldContinueFingerprinting(warnings: warnings) { shouldContinue in
                        assert(Thread.isMainThread, "Completion must be called on main thread.")
                        if shouldContinue {
                            context.transaction.getAuthenticationRequestParameters { result in
                                let mappedResult = result
                                    .mapError(errorMapper.convert)
                                    .flatMap(authenticationRequestMapper.convert)
                                switch mappedResult {
                                case .success:
                                    self?.state = .fingerprinted(context)
                                case .failure:
                                    self?.setIdleState()
                                }
                                completion(mappedResult)
                            }
                        } else {
                            self?.setIdleState()
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

    func perform(
        challenge: PO3DSChallenge, completion: @escaping (Result<Bool, POFailure>) -> Void
    ) {
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

    func redirect(
        context: PORedirectCustomerActionContext, completion: @escaping (Result<String, POFailure>) -> Void
    ) {
        // Redirection is simply forwarded to delegate without additional validations.
        delegate.redirect(context: context, completion: completion)
    }

    // MARK: - Private Nested Types

    private typealias State = CheckoutThreeDSHandlerState

    // MARK: - Private Properties

    private let errorMapper: AuthenticationErrorMapperType
    private let authenticationRequestMapper: AuthenticationRequestMapperType
    private let queue: DispatchQueue
    private unowned let delegate: POCheckoutThreeDSHandlerDelegate

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
        data: PODirectoryServerData
    ) -> ThreeDS2ServiceConfiguration.ConfigParameters {
        // TODO: replace certificate with proper values when available
        let directoryServerData = ThreeDS2ServiceConfiguration.DirectoryServerData(
            directoryServerID: data.id,
            directoryServerPublicKey: data.publicKey,
            directoryServerRootCertificate: "???"
        )
        return .init(directoryServerData: directoryServerData, messageVersion: data.messageVersion, scheme: "")
    }

    private func convertToChallengeParameters(data: PO3DSChallenge) -> ChallengeParameters {
        let challengeParameters = ChallengeParameters(
            threeDSServerTransactionID: data.threeDSServerTransactionId,
            acsTransactionID: data.acsTransactionId,
            acsRefNumber: data.acsReferenceNumber,
            acsSignedContent: data.acsSignedContent
        )
        return challengeParameters
    }
}
