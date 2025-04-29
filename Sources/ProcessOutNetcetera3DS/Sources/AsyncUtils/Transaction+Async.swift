//
//  Transaction+Async.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2025.
//

import ThreeDS_SDK

extension Transaction {

    /// Initiates the challenge process.
    @MainActor
    func doChallenge(
        challengeParameters: ChallengeParameters, timeout: Int, in viewController: UIViewController
    ) async throws -> ChallengeStatus {
        try await withCheckedThrowingContinuation { continuation in
            let statusReceiver = BlockChallengeStatusReceiver { status in
                continuation.resume(returning: status)
            }
            do {
                try doChallenge(
                    challengeParameters: challengeParameters,
                    challengeStatusReceiver: statusReceiver,
                    timeOut: timeout,
                    inViewController: viewController
                )
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

enum ChallengeStatus {

    /// Successful completion.
    case completed(CompletionEvent)

    /// Cardholder selects the option to cancel the transaction on the challenge screen.
    case cancelled

    /// Challenge process reaches or exceeds the specified timeout.
    case timedOut

    /// EMV 3-D Secure protocol-defined error message from the ACS.
    case protocolError(ProtocolErrorEvent)

    /// Errors during the challenge process.
    case runtimeError(RuntimeErrorEvent)
}

private final class BlockChallengeStatusReceiver: ChallengeStatusReceiver {

    init(completion: @Sendable @escaping (ChallengeStatus) -> Void) {
        self.completion = completion
    }

    // MARK: - ChallengeStatusReceiver

    func completed(completionEvent: CompletionEvent) {
        completion(.completed(completionEvent))
    }

    func cancelled() {
        completion(.cancelled)
    }

    func timedout() {
        completion(.timedOut)
    }

    func protocolError(protocolErrorEvent: ProtocolErrorEvent) {
        completion(.protocolError(protocolErrorEvent))
    }

    func runtimeError(runtimeErrorEvent: RuntimeErrorEvent) {
        completion(.runtimeError(runtimeErrorEvent))
    }

    // MARK: - Private Properties

    private let completion: @Sendable (ChallengeStatus) -> Void
}
