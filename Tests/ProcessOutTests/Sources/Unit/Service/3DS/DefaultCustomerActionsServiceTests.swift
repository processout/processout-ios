//
//  DefaultCustomerActionsServiceTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.04.2023.
//

import Foundation
import Testing
@testable @_spi(PO) import ProcessOut

struct DefaultThreeDSServiceTests {

    init() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        webSession = MockWebAuthenticationSession()
        sut = DefaultCustomerActionsService(
            decoder: JSONDecoder(),
            encoder: encoder,
            jsonWritingOptions: [.sortedKeys],
            webSession: webSession,
            logger: .stub
        )
        threeDSService = Mock3DS2Service()
    }

    // MARK: - Fingerprint Mobile

    @Test(arguments: ["%", "{}", "e10="])
    func handle_whenFingerprintMobileValueIsNotBase64EncodedConfiguration_fails(value: String) async throws {
        // Given
        let customerAction = _CustomerAction(type: .fingerprintMobile, value: value)

        // When
        try await withKnownIssue {
            _ = try await sut.handle(
                request: .init(
                    customerAction: customerAction,
                    webAuthenticationCallback: nil,
                    prefersEphemeralWebAuthenticationSession: true
                ),
                threeDSService: threeDSService
            )
        } matching: { issue in
            if let failure = issue.error as? POFailure, case .internal(.mobile) = failure.code {
                return true
            }
            return false
        }
    }

    @Test(
        arguments: [
            Self.defaultFingerprintMobileCustomerAction(),
            Self.defaultFingerprintMobileCustomerAction(padded: true)
        ]
    )
    func handle_whenFingerprintMobileValueIsValid_callsDelegateAuthenticationRequest(
        customerAction: _CustomerAction
    ) async {
        // Given
        let expectedConfiguration = PO3DS2Configuration(
            directoryServerId: "1",
            directoryServerPublicKey: "2",
            directoryServerRootCertificates: ["3"],
            directoryServerTransactionId: "4",
            scheme: .init(rawValue: "5"),
            messageVersion: "6"
        )
        threeDSService.authenticationRequestParametersFromClosure = { configuration in
            #expect(configuration == expectedConfiguration)
            throw POFailure(code: .generic(.mobile))
        }

        // When
        _ = try? await sut.handle(
            request: .init(
                customerAction: customerAction,
                webAuthenticationCallback: nil,
                prefersEphemeralWebAuthenticationSession: true
            ),
            threeDSService: threeDSService
        )

        // Then
        #expect(threeDSService.authenticationRequestParametersCallsCount == 1)
    }

    @Test
    func handle_whenDelegateAuthenticationRequestFails_propagatesFailure() async throws {
        // Given
        let expectedError = POFailure(code: .unknown(rawValue: "test-error"))
        threeDSService.authenticationRequestParametersFromClosure = { _ in
            throw expectedError
        }
        let customerAction = Self.defaultFingerprintMobileCustomerAction()

        // When
        try await withKnownIssue {
            _ = try await sut.handle(
                request: .init(
                    customerAction: customerAction,
                    webAuthenticationCallback: nil,
                    prefersEphemeralWebAuthenticationSession: true
                ),
                threeDSService: threeDSService
            )
        } matching: { issue in
            if let failure = issue.error as? POFailure, failure.code == expectedError.code {
                return true
            }
            return false
        }
    }

    @Test
    func handle_whenAuthenticationRequestPublicKeyIsEmpty_fails() async throws {
        // Given
        threeDSService.authenticationRequestParametersFromClosure = { _ in
            .init(deviceData: "", sdkAppId: "", sdkEphemeralPublicKey: "", sdkReferenceNumber: "", sdkTransactionId: "")
        }
        let customerAction = Self.defaultFingerprintMobileCustomerAction()

        // When
        try await withKnownIssue {
            _ = try await sut.handle(
                request: .init(
                    customerAction: customerAction,
                    webAuthenticationCallback: nil,
                    prefersEphemeralWebAuthenticationSession: true
                ),
                threeDSService: threeDSService
            )
        } matching: { issue in
            if let failure = issue.error as? POFailure, case .internal(.mobile) = failure.code {
                return true
            }
            return false
        }
        #expect(threeDSService.authenticationRequestParametersCallsCount == 1)
    }

    @Test
    func handle_whenAuthenticationRequestIsValid_succeeds() async throws {
        // Given
        let customerAction = Self.defaultFingerprintMobileCustomerAction()
        threeDSService.authenticationRequestParametersFromClosure = { _ in
            PO3DS2AuthenticationRequestParameters(
                deviceData: "1",
                sdkAppId: "2",
                sdkEphemeralPublicKey: #"{"kty": "EC"}"#,
                sdkReferenceNumber: "3",
                sdkTransactionId: "4"
            )
        }

        // When
        let token = try await sut.handle(
            request: .init(
                customerAction: customerAction,
                webAuthenticationCallback: nil,
                prefersEphemeralWebAuthenticationSession: true
            ),
            threeDSService: threeDSService
        )

        // Then
        let expectedToken = """
            gway_req_eyJib2R5Ijoie1wiZGV2aWNlQ2hhbm5lbFwiOlwiYXBwXCIsXCJzZGtBcHBJRFwiOlwiMlwiLFwic2RrR\
            W5jRGF0YVwiOlwiMVwiLFwic2RrRXBoZW1QdWJLZXlcIjp7XCJrdHlcIjpcIkVDXCJ9LFwic2RrUmVmZXJlbmNlTnV\
            tYmVyXCI6XCIzXCIsXCJzZGtUcmFuc0lEXCI6XCI0XCJ9In0=
            """
        #expect(token == expectedToken)
    }

    // MARK: - Challenge Mobile

    @Test
    func handle_whenChallengeMobileValueIsNotValid_fails() async throws {
        // Given
        let customerAction = _CustomerAction(type: .challengeMobile, value: "")

        // When
        try await withKnownIssue {
            _ = try await sut.handle(
                request: .init(
                    customerAction: customerAction,
                    webAuthenticationCallback: nil,
                    prefersEphemeralWebAuthenticationSession: true
                ),
                threeDSService: threeDSService
            )
        } matching: { issue in
            if let failure = issue.error as? POFailure {
                return failure.code == .internal(.mobile)
            }
            return false
        }
    }

    @Test
    func handle_whenChallengeMobileValueIsValid_callsDelegateDoChallenge() async throws {
        // Given
        let expectedChallenge = PO3DS2ChallengeParameters(
            acsTransactionId: "1",
            acsReferenceNumber: "2",
            acsSignedContent: "3",
            threeDSServerTransactionId: "4"
        )
        threeDSService.performChallengeFromClosure = { challenge in
            // Then
            #expect(challenge == expectedChallenge)
            return .init(transactionStatus: true)
        }

        // When
        _ = try await sut.handle(
            request: .init(
                customerAction: Self.defaultChallengeMobileCustomerAction,
                webAuthenticationCallback: nil,
                prefersEphemeralWebAuthenticationSession: true
            ),
            threeDSService: threeDSService
        )
        #expect(threeDSService.performChallengeCallsCount == 1)
    }

    @Test
    func handle_whenDelegateDoChallengeFails_propagatesFailure() async throws {
        // Given
        let expectedError = POFailure(code: .unknown(rawValue: "test-error"))
        threeDSService.performChallengeFromClosure = { _ in
            throw expectedError
        }

        // When
        try await withKnownIssue {
            _ = try await sut.handle(
                request: .init(
                    customerAction: Self.defaultChallengeMobileCustomerAction,
                    webAuthenticationCallback: nil,
                    prefersEphemeralWebAuthenticationSession: true
                ),
                threeDSService: threeDSService
            )
        } matching: { issue in
            if let failure = issue.error as? POFailure {
                return failure.code == expectedError.code
            }
            return false
        }
    }

    @Test
    func handle_whenDelegateDoChallengeCompletesWithTrue_succeeds() async throws {
        // Given
        threeDSService.performChallengeFromClosure = { _ in
            .init(transactionStatus: true)
        }

        // When
        let token = try await sut.handle(
            request: .init(
                customerAction: Self.defaultChallengeMobileCustomerAction,
                webAuthenticationCallback: nil,
                prefersEphemeralWebAuthenticationSession: true
            ),
            threeDSService: threeDSService
        )

        // Then
        #expect(token == "gway_req_eyJib2R5Ijoie1widHJhbnNTdGF0dXNcIjpcIllcIn0ifQ==")
    }

    @Test
    func handle_whenDelegateDoChallengeCompletesWithFalse_succeeds() async throws {
        // Given
        threeDSService.performChallengeFromClosure = { _ in
            .init(transactionStatus: false)
        }

        // When
        let token = try await sut.handle(
            request: .init(
                customerAction: Self.defaultChallengeMobileCustomerAction,
                webAuthenticationCallback: nil,
                prefersEphemeralWebAuthenticationSession: true
            ),
            threeDSService: threeDSService
        )

        // Then
        #expect(token == "gway_req_eyJib2R5Ijoie1widHJhbnNTdGF0dXNcIjpcIk5cIn0ifQ==")
    }

    // MARK: - Redirect

    @Test(arguments: [_CustomerAction.ActionType.url, .fingerprint])
    func handle_whenActionTypeIsUrlOrFingerprint_callsWebSession(actionType: _CustomerAction.ActionType) async throws {
        // Given
        let customerAction = _CustomerAction(type: actionType, value: "example.com")
        webSession.authenticateFromClosure = { _ in
            URL(string: "example.com")!
        }

        // When
        _ = try await sut.handle(
            request: .init(
                customerAction: customerAction,
                webAuthenticationCallback: nil,
                prefersEphemeralWebAuthenticationSession: true
            ),
            threeDSService: threeDSService
        )

        // Then
        #expect(webSession.authenticateCallsCount == 1)
    }

    @Test(arguments: [_CustomerAction.ActionType.redirect, .url, .fingerprint])
    func handle_whenRedirectOrFingerprintValueIsNotValidUrl_fails(actionType: _CustomerAction.ActionType) async throws {
        // Given
        let customerAction = _CustomerAction(type: actionType, value: "")

        // When
        try await withKnownIssue {
            _ = try await sut.handle(
                request: .init(
                    customerAction: customerAction,
                    webAuthenticationCallback: nil,
                    prefersEphemeralWebAuthenticationSession: true
                ),
                threeDSService: threeDSService
            )
        } matching: { issue in
            if let failure = issue.error as? POFailure {
                return failure.code == .internal(.mobile)
            }
            return false
        }
    }

    @Test
    func handle_whenRedirectValueIsValidUrl_callsWebSession() async throws {
        // Given
        webSession.authenticateFromClosure = { request in
            #expect(URL(string: "example.com") == request.url)
            return URL(string: "test://return")!
        }
        let customerAction = _CustomerAction(type: .redirect, value: "example.com")

        // When
        _ = try await sut.handle(
            request: .init(
                customerAction: customerAction,
                webAuthenticationCallback: nil,
                prefersEphemeralWebAuthenticationSession: true
            ),
            threeDSService: threeDSService
        )
        #expect(webSession.authenticateCallsCount == 1)
    }

    @Test
    func handle_whenRedirectCompletesWithNewToken_propagatesToken() async throws {
        // Given
        webSession.authenticateFromClosure = { _ in
            URL(string: "test://return?token=test")!
        }
        let customerAction = _CustomerAction(type: .redirect, value: "example.com")

        // When
        let value = try await sut.handle(
            request: .init(
                customerAction: customerAction,
                webAuthenticationCallback: nil,
                prefersEphemeralWebAuthenticationSession: true
            ),
            threeDSService: threeDSService
        )

        // Then
        #expect(value == "test")
    }

    @Test
    func handle_whenRedirectFails_propagatesError() async throws {
        // Given
        webSession.authenticateFromClosure = { _ in
            throw POFailure(code: .unknown(rawValue: "test-error"))
        }

        let customerAction = _CustomerAction(type: .redirect, value: "example.com")

        // When
        try await withKnownIssue {
            _ = try await sut.handle(
                request: .init(
                    customerAction: customerAction,
                    webAuthenticationCallback: nil,
                    prefersEphemeralWebAuthenticationSession: true
                ),
                threeDSService: threeDSService
            )
        } matching: { issue in
            if let failure = issue.error as? POFailure {
                return failure.code == .unknown(rawValue: "test-error")
            }
            return false
        }
    }

    // MARK: - Fingerprint

    @Test
    func handle_whenFingerprintValueIsValidUrl_callsWebSession() async throws {
        // Given
        let expectedRedirectUrl = URL(string: "example.com")!
        webSession.authenticateFromClosure = { request in
            #expect(request.url == expectedRedirectUrl)
            return URL(string: "test://return")!
        }
        let customerAction = _CustomerAction(type: .fingerprint, value: expectedRedirectUrl.absoluteString)

        // When
        _ = try await sut.handle(
            request: .init(
                customerAction: customerAction,
                webAuthenticationCallback: nil,
                prefersEphemeralWebAuthenticationSession: true
            ),
            threeDSService: threeDSService
        )
        #expect(webSession.authenticateCallsCount == 1)
    }

    @Test
    func handle_whenFingerprintCompletesWithNewToken_propagatesToken() async throws {
        // Given
        webSession.authenticateFromClosure = { _ in
            URL(string: "test://return?token=test")!
        }
        let customerAction = _CustomerAction(type: .fingerprint, value: "example.com")

        // When
        let value = try await sut.handle(
            request: .init(
                customerAction: customerAction,
                webAuthenticationCallback: nil,
                prefersEphemeralWebAuthenticationSession: true
            ),
            threeDSService: threeDSService
        )

        // Then
        #expect(value == "test")
    }

    @Test
    func handle_whenFingerprintFails_propagatesError() async throws {
        // Given
        webSession.authenticateFromClosure = { _ in
            throw POFailure(code: .unknown(rawValue: "test-error"))
        }
        let customerAction = _CustomerAction(type: .fingerprint, value: "example.com")

        // When
        try await withKnownIssue {
            _ = try await sut.handle(
                request: .init(
                    customerAction: customerAction,
                    webAuthenticationCallback: nil,
                    prefersEphemeralWebAuthenticationSession: true
                ),
                threeDSService: threeDSService
            )
        } matching: { issue in
            if let failure = issue.error as? POFailure {
                return failure.code == .unknown(rawValue: "test-error")
            }
            return false
        }
    }

    @Test
    func handle_whenFingerprintFailsWithTimeoutError_succeeds() async throws {
        // Given
        webSession.authenticateFromClosure = { _ in
            throw POFailure(code: .timeout(.mobile))
        }
        let customerAction = _CustomerAction(type: .fingerprint, value: "example.com")

        // When
        let value = try await sut.handle(
            request: .init(
                customerAction: customerAction,
                webAuthenticationCallback: nil,
                prefersEphemeralWebAuthenticationSession: true
            ),
            threeDSService: threeDSService
        )

        // Then
        let expectedValue = """
            gway_req_eyJib2R5IjoieyBcInRocmVlRFMyRmluZ2VycHJpbnRUaW1lb3V0XCI6IHRydWUgfSIsInVybCI6ImV4YW1wbGUuY29tIn0=
            """
        #expect(value == expectedValue)
    }

    @Test
    func handle_whenFingerprintTakesTooLong_succeedsWithTimeout() async throws {
        // Given
        webSession.authenticateFromClosure = { _ in
            try await Task.sleep(seconds: 15)
            return URL(string: "test://return")!
        }
        let customerAction = _CustomerAction(type: .fingerprint, value: "example.com")

        // When
        let value = try await sut.handle(
            request: .init(
                customerAction: customerAction,
                webAuthenticationCallback: nil,
                prefersEphemeralWebAuthenticationSession: true
            ),
            threeDSService: threeDSService
        )

        // Then
        let expectedValue = """
            gway_req_eyJib2R5IjoieyBcInRocmVlRFMyRmluZ2VycHJpbnRUaW1lb3V0XCI6IHRydWUgfSIsInVybCI6ImV4YW1wbGUuY29tIn0=
            """
        #expect(value == expectedValue)
    }

    // MARK: - Private Properties

    private let sut: DefaultCustomerActionsService
    private let threeDSService: Mock3DS2Service!
    private let webSession: MockWebAuthenticationSession!

    // MARK: - Private Methods

    private static func defaultFingerprintMobileCustomerAction(padded: Bool = false) -> _CustomerAction {
        var value = """
            eyJkaXJlY3RvcnlTZXJ2ZXJJRCI6IjEiLCJkaXJlY3RvcnlTZXJ2ZXJQdWJsaWNLZXkiOiIyIiwiZGlyZWN0b3J5U2VydmVyUm9vd\
            ENBcyI6WyIzIl0sInRocmVlRFNTZXJ2ZXJUcmFuc0lEIjoiNCIsInNjaGVtZSI6IjUiLCJtZXNzYWdlVmVyc2lvbiI6IjYifQ
            """
        if padded {
            value += "=="
        }
        return _CustomerAction(type: .fingerprintMobile, value: value)
    }

    private static var defaultChallengeMobileCustomerAction: _CustomerAction {
        let value = """
            eyJhY3NUcmFuc0lEIjoiMSIsImFjc1JlZmVyZW5jZU51bWJlciI6IjIiL\
            CJhY3NTaWduZWRDb250ZW50IjoiMyIsInRocmVlRFNTZXJ2ZXJUcmFuc0lEIjoiNCJ9
            """
        return _CustomerAction(type: .challengeMobile, value: value)
    }
}
