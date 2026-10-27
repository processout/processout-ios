//
//  Netcetera3DS2ServiceTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 30.04.2025.
//

import Foundation
import Testing
@testable import ProcessOutNetcetera3DS
@_spi(PO) @testable import ProcessOut

@Suite(.serialized)
struct Netcetera3DS2ServiceTests {

    init() async {
        processOut = await .init(configuration: .init(projectId: "proj_test"))
    }

    // MARK: -

    @Test
    func authenticationRequestParameters_whenConfigurationIsInvalid_fails() async throws {
        // Given
        let sut = PONetcetera3DS2Service(eventEmitter: processOut.eventEmitter, logger: processOut.logger)
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
    func authenticationRequestParameters_whenDirectoryServerIsKnown_ignoresInvalidPublicKey() async throws {
        // Given
        let sut = PONetcetera3DS2Service(eventEmitter: processOut.eventEmitter, logger: processOut.logger)
        let configuration = PO3DS2Configuration(
            directoryServerId: "A000000003",
            directoryServerPublicKey: "",
            directoryServerRootCertificates: [],
            directoryServerTransactionId: UUID().uuidString,
            messageVersion: "2.3.1"
        )

        // When
        let requestParameters = try await sut.authenticationRequestParameters(configuration: configuration)

        // Then
        #expect(!requestParameters.deviceData.isEmpty)

        // Cleanup
        await sut.clean()
    }

    @Test
    func authenticationRequestParameters_whenDirectoryServerIsUnknown_succeeds() async throws {
        // Given
        let sut = PONetcetera3DS2Service(eventEmitter: processOut.eventEmitter, logger: processOut.logger)
        let configuration = PO3DS2Configuration(
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
            messageVersion: "2.3.1"
        )

        // When
        let requestParameters = try await sut.authenticationRequestParameters(configuration: configuration)

        // Then
        #expect(!requestParameters.deviceData.isEmpty)

        // Cleanup
        await sut.clean()
    }

    // MARK: - State

    @Test
    func authenticationRequestParameters_whenAnotherAuthenticationIsInProgress_fails() async throws {
        // Given
        let sut = PONetcetera3DS2Service(eventEmitter: processOut.eventEmitter, logger: processOut.logger)
        _ = try await sut.authenticationRequestParameters(configuration: Self.knownDirectoryServerConfiguration())

        // When
        await withKnownIssue {
            _ = try await sut.authenticationRequestParameters(configuration: Self.knownDirectoryServerConfiguration())
        }

        // Cleanup
        await sut.clean()
    }

    @Test
    func authenticationRequestParameters_afterFailure_succeeds() async throws {
        // Given
        let sut = PONetcetera3DS2Service(eventEmitter: processOut.eventEmitter, logger: processOut.logger)
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
            configuration: Self.knownDirectoryServerConfiguration()
        )

        // Then
        #expect(!requestParameters.deviceData.isEmpty)

        // Cleanup
        await sut.clean()
    }

    @Test
    func authenticationRequestParameters_afterClean_succeeds() async throws {
        // Given
        let sut = PONetcetera3DS2Service(eventEmitter: processOut.eventEmitter, logger: processOut.logger)
        _ = try await sut.authenticationRequestParameters(configuration: Self.knownDirectoryServerConfiguration())
        await sut.clean()

        // When
        let requestParameters = try await sut.authenticationRequestParameters(
            configuration: Self.knownDirectoryServerConfiguration()
        )

        // Then
        #expect(!requestParameters.deviceData.isEmpty)

        // Cleanup
        await sut.clean()
    }

    @Test
    func performChallenge_whenThereIsNoTransaction_fails() async throws {
        // Given
        let sut = PONetcetera3DS2Service(eventEmitter: processOut.eventEmitter, logger: processOut.logger)
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
        let sut = PONetcetera3DS2Service(eventEmitter: processOut.eventEmitter, logger: processOut.logger)
        _ = try await sut.authenticationRequestParameters(configuration: Self.knownDirectoryServerConfiguration())
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

    private static func knownDirectoryServerConfiguration() -> PO3DS2Configuration {
        PO3DS2Configuration(
            directoryServerId: "A000000003",
            directoryServerPublicKey: "",
            directoryServerRootCertificates: [],
            directoryServerTransactionId: UUID().uuidString,
            messageVersion: "2.3.1"
        )
    }

    // MARK: - Private Properties

    private let processOut: ProcessOut
}
