//
//  Checkout3DSServiceTransactionTests.swift
//  ProcessOutCheckout3DSTests
//
//  Created by Andrii Vysotskyi on 04.11.2026.
//

import Foundation
import Testing
@testable import ProcessOutCheckout3DS
@_spi(PO) @testable import ProcessOut

@MainActor
struct Checkout3DSServiceTransactionTests {

    init() async {
        processOut = await .init(configuration: .init(projectId: "proj_test"))
        let threeDSService = MockThreeDS2Service()
        self.threeDSService = threeDSService
        sut = POCheckout3DSService(
            eventEmitter: processOut.eventEmitter,
            logger: processOut.logger,
            serviceProvider: { _, _ in threeDSService }
        )
    }

    // MARK: -

    @Test
    func performChallenge_reusesAuthenticationTransaction() async throws {
        // Given
        let configuration = Self.configuration()
        _ = try await sut.authenticationRequestParameters(configuration: configuration)

        // When
        _ = try? await sut.performChallenge(
            with: Self.challengeParameters(transactionId: configuration.directoryServerTransactionId)
        )

        // Then
        #expect(threeDSService.createdTransactions.count == 1)
        #expect(threeDSService.createdTransactions.first?.doChallengeCallsCount == 1)

        // Cleanup
        await sut.clean()
    }

    @Test
    func clean_cleansUpService() async throws {
        // Given
        _ = try await sut.authenticationRequestParameters(configuration: Self.configuration())

        // When
        await sut.clean()

        // Then
        #expect(threeDSService.cleanUpCallsCount == 1)
    }

    // MARK: - Private Methods

    private static func configuration() -> PO3DS2Configuration {
        PO3DS2Configuration(
            directoryServerId: "A000000003",
            directoryServerPublicKey: "",
            directoryServerRootCertificates: [],
            directoryServerTransactionId: UUID().uuidString,
            messageVersion: "2.2.0"
        )
    }

    private static func challengeParameters(transactionId: String) -> PO3DS2ChallengeParameters {
        PO3DS2ChallengeParameters(
            acsTransactionId: "",
            acsReferenceNumber: "",
            acsSignedContent: "",
            threeDSServerTransactionId: transactionId
        )
    }

    // MARK: - Private Properties

    private let processOut: ProcessOut
    private let threeDSService: MockThreeDS2Service
    private let sut: POCheckout3DSService
}
