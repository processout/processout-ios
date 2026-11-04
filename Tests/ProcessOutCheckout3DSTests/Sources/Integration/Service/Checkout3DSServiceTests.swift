//
//  Checkout3DSServiceTests.swift
//  ProcessOutCheckout3DSTests
//
//  Created by Andrii Vysotskyi on 17.04.2023.
//

import Foundation
import Testing
@testable import ProcessOutCheckout3DS
@_spi(PO) @testable import ProcessOut

@MainActor
@Suite(.serialized)
struct Checkout3DSServiceTests {

    init() async {
        processOut = await .init(configuration: .init(projectId: "proj_test"))
    }

    // MARK: -

    @Test
    func authenticationRequestParameters_whenConfigurationIsInvalid_fails() async throws {
        // Given
        let sut = POCheckout3DSService(eventEmitter: processOut.eventEmitter, logger: processOut.logger)
        let configuration = PO3DS2Configuration(
            directoryServerId: "",
            directoryServerPublicKey: "",
            directoryServerRootCertificates: [],
            directoryServerTransactionId: "",
            messageVersion: ""
        )

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
        let sut = POCheckout3DSService(eventEmitter: processOut.eventEmitter, logger: processOut.logger)

        // When
        let requestParameters = try await sut.authenticationRequestParameters(
            configuration: Self.validConfiguration()
        )

        // Then
        #expect(!requestParameters.deviceData.isEmpty)

        // Cleanup
        await sut.clean()
    }

    // MARK: - State

    @Test
    func authenticationRequestParameters_whenAnotherAuthenticationIsInProgress_fails() async throws {
        // Given
        let sut = POCheckout3DSService(eventEmitter: processOut.eventEmitter, logger: processOut.logger)
        _ = try await sut.authenticationRequestParameters(configuration: Self.validConfiguration())

        // When
        await withKnownIssue {
            _ = try await sut.authenticationRequestParameters(configuration: Self.validConfiguration())
        }

        // Cleanup
        await sut.clean()
    }

    @Test
    func authenticationRequestParameters_afterFailure_succeeds() async throws {
        // Given
        let sut = POCheckout3DSService(eventEmitter: processOut.eventEmitter, logger: processOut.logger)
        let invalidConfiguration = PO3DS2Configuration(
            directoryServerId: "",
            directoryServerPublicKey: "",
            directoryServerRootCertificates: [],
            directoryServerTransactionId: "",
            messageVersion: ""
        )
        await withKnownIssue {
            _ = try await sut.authenticationRequestParameters(configuration: invalidConfiguration)
        }

        // When
        let requestParameters = try await sut.authenticationRequestParameters(
            configuration: Self.validConfiguration()
        )

        // Then
        #expect(!requestParameters.deviceData.isEmpty)

        // Cleanup
        await sut.clean()
    }

    @Test
    func authenticationRequestParameters_afterClean_succeeds() async throws {
        // Given
        let sut = POCheckout3DSService(eventEmitter: processOut.eventEmitter, logger: processOut.logger)
        _ = try await sut.authenticationRequestParameters(configuration: Self.validConfiguration())
        await sut.clean()

        // When
        let requestParameters = try await sut.authenticationRequestParameters(
            configuration: Self.validConfiguration()
        )

        // Then
        #expect(!requestParameters.deviceData.isEmpty)

        // Cleanup
        await sut.clean()
    }

    @Test
    func performChallenge_whenThereIsNoTransaction_fails() async throws {
        // Given
        let sut = POCheckout3DSService(eventEmitter: processOut.eventEmitter, logger: processOut.logger)
        let parameters = PO3DS2ChallengeParameters(
            acsTransactionId: "", acsReferenceNumber: "", acsSignedContent: "", threeDSServerTransactionId: ""
        )

        // When
        await withKnownIssue {
            _ = try await sut.performChallenge(with: parameters)
        }
    }

    @Test
    func performChallenge_whenTransactionIdDoesNotMatch_fails() async throws {
        // Given
        let sut = POCheckout3DSService(eventEmitter: processOut.eventEmitter, logger: processOut.logger)
        _ = try await sut.authenticationRequestParameters(configuration: Self.validConfiguration())
        let parameters = PO3DS2ChallengeParameters(
            acsTransactionId: "", acsReferenceNumber: "", acsSignedContent: "", threeDSServerTransactionId: "other"
        )

        // When
        await withKnownIssue {
            _ = try await sut.performChallenge(with: parameters)
        }

        // Cleanup
        await sut.clean()
    }

    // MARK: - Private Methods

    private static func validConfiguration() -> PO3DS2Configuration {
        PO3DS2Configuration(
            directoryServerId: "0000123456",
            directoryServerPublicKey:
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
            directoryServerRootCertificates: [],
            directoryServerTransactionId: UUID().uuidString,
            messageVersion: "2.2.0"
        )
    }

    // MARK: - Private Properties

    private let processOut: ProcessOut
}
