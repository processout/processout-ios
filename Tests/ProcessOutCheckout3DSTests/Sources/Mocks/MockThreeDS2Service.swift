//
//  MockThreeDS2Service.swift
//  ProcessOutCheckout3DSTests
//
//  Created by Andrii Vysotskyi on 04.11.2026.
//

import Checkout3DS

@MainActor
final class MockThreeDS2Service: ThreeDS2Service {

    /// Transactions created by service in order of creation.
    private(set) var createdTransactions: [MockTransaction] = []

    private(set) var cleanUpCallsCount = 0

    // MARK: - ThreeDS2Service

    nonisolated func createTransaction() -> any Transaction {
        MainActor.assumeIsolated {
            let transaction = MockTransaction()
            createdTransactions.append(transaction)
            return transaction
        }
    }

    nonisolated func getWarnings() -> Set<Warning> {
        []
    }

    nonisolated func cleanUp() {
        MainActor.assumeIsolated {
            cleanUpCallsCount += 1
        }
    }
}

@MainActor
final class MockTransaction: Transaction {

    private(set) var doChallengeCallsCount = 0

    // MARK: - Transaction

    nonisolated func getAuthenticationRequestParameters(
        completion: @escaping (Result<AuthenticationRequestParameters, AuthenticationError>) -> Void
    ) {
        let parameters = AuthenticationRequestParameters(
            deviceData: "device-data",
            sdkTransactionID: "sdk-transaction-id",
            sdkAppID: "sdk-app-id",
            sdkReferenceNumber: "sdk-reference-number",
            sdkEphemeralPublicKey: "sdk-ephemeral-public-key",
            mssageVersion: "2.2.0"
        )
        completion(.success(parameters))
    }

    nonisolated func doChallenge(
        challengeParameters: ChallengeParameters,
        completion: @escaping (Result<AuthenticationResult, AuthenticationError>) -> Void
    ) {
        MainActor.assumeIsolated {
            doChallengeCallsCount += 1
        }
        // AuthenticationResult can't be constructed outside of Checkout3DS.
        completion(.failure(.challengeCancelled))
    }

    nonisolated func setProtocolErrorListener(_ listener: ((ProtocolErrorEvent) -> Void)?) {
        // Ignored
    }

    nonisolated func close() {
        // Ignored
    }
}
