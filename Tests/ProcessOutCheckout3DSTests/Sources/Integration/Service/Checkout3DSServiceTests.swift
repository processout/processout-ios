//
//  Checkout3DSServiceTests.swift
//  ProcessOutCheckout3DSTests
//
//  Created by Andrii Vysotskyi on 17.04.2023.
//

import Foundation
import Testing
import ProcessOut
import ProcessOutCheckout3DS
import Checkout3DS

@MainActor
@Suite(.serialized)
struct Checkout3DSServiceTests {

    init() {
        ProcessOut.configure(configuration: .init(projectId: "proj_test"))
    }

    // MARK: -

    @Test
    func authenticationRequestParameters_whenConfigurationIsInvalid_fails() async throws {
        // Given
        let sut = POCheckout3DSService()
        let configuration = try Self.invalidConfiguration()

        // When
        await withKnownIssue {
            _ = try await sut.authenticationRequestParameters(configuration: configuration)
        }

        // Cleanup
        await sut.clean()
    }

    @Test
    func authenticationRequestParameters_whenConfigurationIsValid_succeeds() async throws {
        // Given
        let sut = POCheckout3DSService()

        // When
        let requestParameters = try await sut.authenticationRequestParameters(
            configuration: try Self.validConfiguration()
        )

        // Then
        #expect(!requestParameters.deviceData.isEmpty)

        // Cleanup
        await sut.clean()
    }

    // MARK: - State

    @Test
    func authenticationRequestParameters_whenPreviousTransactionIsNotCleaned_fails() async throws {
        // Given
        let sut = POCheckout3DSService()
        _ = try await sut.authenticationRequestParameters(configuration: try Self.validConfiguration())

        // When
        let failure = await #expect(throws: POFailure.self) {
            _ = try await sut.authenticationRequestParameters(configuration: try Self.validConfiguration())
        }

        // Then
        #expect(failure?.message == "Previous transaction was not cleaned, call clean() first.")

        // Cleanup
        await sut.clean()
    }

    @Test
    func authenticationRequestParameters_whenAnotherAuthenticationIsInProgress_fails() async throws {
        // Given
        let delegate = SuspendingDelegate()
        let sut = POCheckout3DSService(delegate: delegate)
        let configuration = try Self.validConfiguration()
        let authentication = Task {
            try await sut.authenticationRequestParameters(configuration: configuration)
        }
        await delegate.waitForSuspension()

        // When
        let failure = await #expect(throws: POFailure.self) {
            _ = try await sut.authenticationRequestParameters(configuration: try Self.validConfiguration())
        }

        // Then
        #expect(failure?.message == "Another operation is already in progress.")
        delegate.resume()
        let requestParameters = try await authentication.value
        #expect(!requestParameters.deviceData.isEmpty)

        // Cleanup
        await sut.clean()
    }

    @Test
    func authenticationRequestParameters_afterFailure_succeeds() async throws {
        // Given
        let sut = POCheckout3DSService()
        let invalidConfiguration = try Self.invalidConfiguration()
        await withKnownIssue {
            _ = try await sut.authenticationRequestParameters(configuration: invalidConfiguration)
        }

        // When
        let requestParameters = try await sut.authenticationRequestParameters(
            configuration: try Self.validConfiguration()
        )

        // Then
        #expect(!requestParameters.deviceData.isEmpty)

        // Cleanup
        await sut.clean()
    }

    @Test
    func authenticationRequestParameters_afterClean_succeeds() async throws {
        // Given
        let sut = POCheckout3DSService()
        _ = try await sut.authenticationRequestParameters(configuration: try Self.validConfiguration())
        await sut.clean()

        // When
        let requestParameters = try await sut.authenticationRequestParameters(
            configuration: try Self.validConfiguration()
        )

        // Then
        #expect(!requestParameters.deviceData.isEmpty)

        // Cleanup
        await sut.clean()
    }

    @Test
    func performChallenge_whenThereIsNoTransaction_fails() async throws {
        // Given
        let sut = POCheckout3DSService()
        let parameters = try Self.challengeParameters(transactionId: "")

        // When
        let failure = await #expect(throws: POFailure.self) {
            _ = try await sut.performChallenge(with: parameters)
        }

        // Then
        #expect(failure?.message == "Unable to resolve current transaction.")
    }

    @Test
    func performChallenge_whenTransactionIdDoesNotMatch_fails() async throws {
        // Given
        let sut = POCheckout3DSService()
        _ = try await sut.authenticationRequestParameters(configuration: try Self.validConfiguration())
        let parameters = try Self.challengeParameters(transactionId: "other")

        // When
        let failure = await #expect(throws: POFailure.self) {
            _ = try await sut.performChallenge(with: parameters)
        }

        // Then
        #expect(failure?.message == "Unable to resolve current transaction.")

        // Cleanup
        await sut.clean()
    }

    // MARK: - Private Methods

    private static func validConfiguration() throws -> PO3DS2Configuration {
        try decode(
            [
                "directoryServerID": "0000123456",
                "directoryServerPublicKey":
                    """
                    ewogICJrdHkiOiAiUlNBIiwKICAia2lkIjogImU0ODA1NGNkLTkxNDgtNGE3ZS1h\
                    MjE5LWYyMTA1NzEyZmZkMyIsCiAgIm4iOiAiejZjWDFIMDRrTHRqcnJ2elIxVndz\
                    OUtMTmF0ZkVOQ0JkMDliLUx4eDlKbENTMjRQaFZwbnBmU1ZrTThTYmNlWW9sLXJB\
                    UUZTanYtVVpsTEFiUGY1R2lCNG9aSUV4XzBMc2V1WlNRZHNQNDVjM3FsVXc3eXFY\
                    RmZDUVVqbUl0NEtvWndwOWNGdG1rRDFSemg1OFo0cjAzTnB6OVJ4X2dZQWk3bXlT\
                    WGhSZ3IxYTBla3h6QjdoTDZDckRoNGRyTFJ3dEhfTHN3ZzBpRzBnUmRVVEdrZXNp\
                    TU14RnFRa3ZDQ0loQUIxVFEzNnctUHQtYk8yWXFFUDMteWIwd1dicU9CQ0lseGRH\
                    UXh2V0gydkJsTkNCZDhrMjNVYUZiYlYzVE9rWVQtdGhkOXByM0RuQ3JXWUdpWTdB\
                    NVF3MUdDS0FCd3QtOWF0OHZOQnQ4Q2Q4WXNXeFk0a3JRIiwKICAiZSI6ICJBUUFC\
                    IiwKfQ
                    """,
                "directoryServerRootCAs": [],
                "threeDSServerTransID": UUID().uuidString,
                "messageVersion": "2.2.0"
            ]
        )
    }

    private static func invalidConfiguration() throws -> PO3DS2Configuration {
        try decode(
            [
                "directoryServerID": "",
                "directoryServerPublicKey": "",
                "directoryServerRootCAs": [],
                "threeDSServerTransID": "",
                "messageVersion": ""
            ]
        )
    }

    private static func challengeParameters(transactionId: String) throws -> PO3DS2ChallengeParameters {
        try decode(
            [
                "acsTransID": "",
                "acsReferenceNumber": "",
                "acsSignedContent": "",
                "threeDSServerTransID": transactionId
            ]
        )
    }

    /// Request types have no public initializers, so fixtures are decoded the same way the SDK
    /// receives them from the API.
    private static func decode<T: Decodable>(_ object: [String: Any]) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: object)
        return try JSONDecoder().decode(T.self, from: data)
    }
}

/// Suspends authentication when asked whether to continue, until resumed by the test.
@MainActor
private final class SuspendingDelegate: POCheckout3DSServiceDelegate {

    func waitForSuspension() async {
        guard continuation == nil else {
            return
        }
        await withCheckedContinuation { suspensionContinuation = $0 }
    }

    func resume() {
        continuation?.resume(returning: true)
        continuation = nil
    }

    // MARK: - POCheckout3DSServiceDelegate

    func checkout3DSService(_ service: POCheckout3DSService, shouldContinueWith warnings: Set<Warning>) async -> Bool {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            suspensionContinuation?.resume()
            suspensionContinuation = nil
        }
    }

    // MARK: - Private Properties

    private var continuation: CheckedContinuation<Bool, Never>?
    private var suspensionContinuation: CheckedContinuation<Void, Never>?
}
