//
//  DefaultCustomerActionsServiceTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.04.2023.
//

import Foundation
import XCTest
@testable @_spi(PO) import ProcessOut

final class DefaultThreeDSServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
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

    func test_handle_whenFingerprintMobileValueIsNotBase64EncodedConfiguration_fails() async {
        // Given
        let values = ["%", "{}", "e10="]

        for value in values {
            let customerAction = _CustomerAction(type: .fingerprintMobile, value: value)

            // When
            let failure = await assertThrowsError(
                try await sut.handle(
                    action: customerAction, threeDSService: threeDSService, webAuthenticationCallback: nil
                ),
                errorType: POFailure.self
            )

            // Then
            XCTAssertEqual(failure?.code, .internal(.mobile))
        }
    }

    func test_handle_whenFingerprintMobileValueIsValid_callsDelegateAuthenticationRequest() async {
        // Given
        let customerActions = [
            defaultFingerprintMobileCustomerAction(),
            defaultFingerprintMobileCustomerAction(padded: false)
        ]
        let expectedConfiguration = PO3DS2Configuration(
            directoryServerId: "1",
            directoryServerPublicKey: "2",
            directoryServerRootCertificates: ["3"],
            directoryServerTransactionId: "4",
            scheme: .init(rawValue: "5"),
            messageVersion: "6"
        )
        var delegateCallsCount = 0

        for customerAction in customerActions {
            threeDSService.authenticationRequestParametersFromClosure = { configuration in
                // Then
                XCTAssertEqual(configuration, expectedConfiguration)
                delegateCallsCount += 1
                throw POFailure(code: .generic(.mobile))
            }

            // When
            _ = try? await sut.handle(
                action: customerAction, threeDSService: threeDSService, webAuthenticationCallback: nil
            )
        }
        XCTAssertEqual(delegateCallsCount, customerActions.count)
    }

    func test_handle_whenDelegateAuthenticationRequestFails_propagatesFailure() async {
        // Given
        let expectedError = POFailure(code: .unknown(rawValue: "test-error"))
        threeDSService.authenticationRequestParametersFromClosure = { _ in
            throw expectedError
        }
        let customerAction = defaultFingerprintMobileCustomerAction()

        // When
        let failure = await assertThrowsError(
            try await sut.handle(
                action: customerAction, threeDSService: threeDSService, webAuthenticationCallback: nil
            ),
            errorType: POFailure.self
        )

        // Then
        XCTAssertEqual(failure?.code, expectedError.code)
    }

    func test_handle_whenAuthenticationRequestPublicKeyIsEmpty_fails() async {
        // Given
        var isDelegateCalled = false
        threeDSService.authenticationRequestParametersFromClosure = { _ in
            isDelegateCalled = true
            return .init(
                deviceData: "", sdkAppId: "", sdkEphemeralPublicKey: "", sdkReferenceNumber: "", sdkTransactionId: ""
            )
        }
        let customerAction = defaultFingerprintMobileCustomerAction()

        // When
        let failure = await assertThrowsError(
            try await sut.handle(
                action: customerAction, threeDSService: threeDSService, webAuthenticationCallback: nil
            ),
            errorType: POFailure.self
        )

        // Then
        XCTAssertEqual(failure?.code, .internal(.mobile))
        XCTAssertTrue(isDelegateCalled)
    }

    func test_handle_whenAuthenticationRequestIsValid_succeeds() async throws {
        // Given
        let customerAction = defaultFingerprintMobileCustomerAction()
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
            action: customerAction, threeDSService: threeDSService, webAuthenticationCallback: nil
        )

        // Then
        let expectedToken = """
            gway_req_eyJib2R5Ijoie1wiZGV2aWNlQ2hhbm5lbFwiOlwiYXBwXCIsXCJzZGtBcHBJRFwiOlwiMlwiLFwic2RrR\
            W5jRGF0YVwiOlwiMVwiLFwic2RrRXBoZW1QdWJLZXlcIjp7XCJrdHlcIjpcIkVDXCJ9LFwic2RrUmVmZXJlbmNlTnV\
            tYmVyXCI6XCIzXCIsXCJzZGtUcmFuc0lEXCI6XCI0XCJ9In0=
            """
        XCTAssertEqual(token, expectedToken)
    }

    // MARK: - Challenge Mobile

    func test_handle_whenChallengeMobileValueIsNotValid_fails() async {
        // Given
        let customerAction = _CustomerAction(type: .challengeMobile, value: "")

        // When
        let failure = await assertThrowsError(
            try await sut.handle(
                action: customerAction, threeDSService: threeDSService, webAuthenticationCallback: nil
            ),
            errorType: POFailure.self
        )

        // Then
        XCTAssertEqual(failure?.code, .internal(.mobile))
    }

    func test_handle_whenChallengeMobileValueIsValid_callsDelegateDoChallenge() async throws {
        // Given
        let expectedChallenge = PO3DS2ChallengeParameters(
            acsTransactionId: "1",
            acsReferenceNumber: "2",
            acsSignedContent: "3",
            threeDSServerTransactionId: "4"
        )
        var isDelegateCalled = false
        threeDSService.performChallengeFromClosure = { challenge in
            // Then
            XCTAssertEqual(challenge, expectedChallenge)
            isDelegateCalled = true
            return .init(transactionStatus: true)
        }

        // When
        _ = try await sut.handle(
            action: defaultChallengeMobileCustomerAction, threeDSService: threeDSService, webAuthenticationCallback: nil
        )
        XCTAssertTrue(isDelegateCalled)
    }

    func test_handle_whenDelegateDoChallengeFails_propagatesFailure() async {
        // Given
        let expectedError = POFailure(code: .unknown(rawValue: "test-error"))
        threeDSService.performChallengeFromClosure = { _ in
            throw expectedError
        }

        // When
        let failure = await assertThrowsError(
            try await sut.handle(
                action: defaultChallengeMobileCustomerAction,
                threeDSService: threeDSService,
                webAuthenticationCallback: nil
            ),
            errorType: POFailure.self
        )

        // Then
        XCTAssertEqual(failure?.code, expectedError.code)
    }

    func test_handle_whenDelegateDoChallengeCompletesWithTrue_succeeds() async throws {
        // Given
        threeDSService.performChallengeFromClosure = { _ in
            .init(transactionStatus: true)
        }

        // When
        let token = try await sut.handle(
            action: defaultChallengeMobileCustomerAction, threeDSService: threeDSService, webAuthenticationCallback: nil
        )

        // Then
        XCTAssertEqual(token, "gway_req_eyJib2R5Ijoie1widHJhbnNTdGF0dXNcIjpcIllcIn0ifQ==")
    }

    func test_handle_whenDelegateDoChallengeCompletesWithFalse_succeeds() async throws {
        // Given
        threeDSService.performChallengeFromClosure = { _ in
            .init(transactionStatus: false)
        }

        // When
        let token = try await sut.handle(
            action: defaultChallengeMobileCustomerAction, threeDSService: threeDSService, webAuthenticationCallback: nil
        )

        // Then
        XCTAssertEqual(token, "gway_req_eyJib2R5Ijoie1widHJhbnNTdGF0dXNcIjpcIk5cIn0ifQ==")
    }

    // MARK: - Redirect

    func test_handle_whenActionTypeIsUrlOrFingerprint_callsWebSession() async throws {
        // Given
        webSession.authenticateFromClosure = { _ in
            URL(string: "example.com")!
        }
        let actionTypes: [_CustomerAction.ActionType] = [.url, .fingerprint]

        for actionType in actionTypes {
            let customerAction = _CustomerAction(type: actionType, value: "example.com")

            // When
            _ = try await sut.handle(
                action: customerAction, threeDSService: threeDSService, webAuthenticationCallback: nil
            )
        }

        // Then
        XCTAssertEqual(webSession.authenticateCallsCount, actionTypes.count)
    }

    func test_handle_whenRedirectOrFingerprintValueIsNotValidUrl_fails() async {
        // Given
        let actionTypes: [_CustomerAction.ActionType] = [.redirect, .url, .fingerprint]

        for actionType in actionTypes {
            let action = _CustomerAction(type: actionType, value: "")

            // When
            let failure = await assertThrowsError(
                try await sut.handle(
                    action: action, threeDSService: threeDSService, webAuthenticationCallback: nil
                ),
                errorType: POFailure.self
            )

            // Then
            XCTAssertEqual(failure?.code, .internal(.mobile))
        }
    }

    func test_handle_whenRedirectValueIsValidUrl_callsWebSession() async throws {
        // Given
        webSession.authenticateFromClosure = { request in
            XCTAssertEqual(URL(string: "example.com"), request.url)
            return URL(string: "test://return")!
        }
        let customerAction = _CustomerAction(type: .redirect, value: "example.com")

        // When
        _ = try await sut.handle(action: customerAction, threeDSService: threeDSService, webAuthenticationCallback: nil)
        XCTAssertEqual(webSession.authenticateCallsCount, 1)
    }

    func test_handle_whenRedirectCompletesWithNewToken_propagatesToken() async throws {
        // Given
        webSession.authenticateFromClosure = { _ in
            URL(string: "test://return?token=test")!
        }
        let customerAction = _CustomerAction(type: .redirect, value: "example.com")

        // When
        let value = try await sut.handle(
            action: customerAction, threeDSService: threeDSService, webAuthenticationCallback: nil
        )

        // Then
        XCTAssertEqual(value, "test")
    }

    func test_handle_whenRedirectFails_propagatesError() async {
        // Given
        webSession.authenticateFromClosure = { _ in
            throw POFailure(code: .unknown(rawValue: "test-error"))
        }

        let customerAction = _CustomerAction(type: .redirect, value: "example.com")

        // When
        let failure = await assertThrowsError(
            try await sut.handle(
                action: customerAction, threeDSService: threeDSService, webAuthenticationCallback: nil
            ),
            errorType: POFailure.self
        )

        // Then
        XCTAssertEqual(failure?.code, .unknown(rawValue: "test-error"))
    }

    // MARK: - Fingerprint

    func test_handle_whenFingerprintValueIsValidUrl_callsWebSession() async throws {
        // Given
        let expectedRedirectUrl = URL(string: "example.com")!
        webSession.authenticateFromClosure = { request in
            XCTAssertEqual(request.url, expectedRedirectUrl)
            return URL(string: "test://return")!
        }
        let customerAction = _CustomerAction(type: .fingerprint, value: expectedRedirectUrl.absoluteString)

        // When
        _ = try await sut.handle(action: customerAction, threeDSService: threeDSService, webAuthenticationCallback: nil)
        XCTAssertEqual(webSession.authenticateCallsCount, 1)
    }

    func test_handle_whenFingerprintCompletesWithNewToken_propagatesToken() async throws {
        // Given
        webSession.authenticateFromClosure = { _ in
            URL(string: "test://return?token=test")!
        }
        let customerAction = _CustomerAction(type: .fingerprint, value: "example.com")

        // When
        let value = try await sut.handle(
            action: customerAction, threeDSService: threeDSService, webAuthenticationCallback: nil
        )

        // Then
        XCTAssertEqual(value, "test")
    }

    func test_handle_whenFingerprintFails_propagatesError() async {
        // Given
        webSession.authenticateFromClosure = { _ in
            throw POFailure(code: .unknown(rawValue: "test-error"))
        }
        let customerAction = _CustomerAction(type: .fingerprint, value: "example.com")

        // When
        let failure = await assertThrowsError(
            try await sut.handle(
                action: customerAction, threeDSService: threeDSService, webAuthenticationCallback: nil
            ),
            errorType: POFailure.self
        )

        // Then
        XCTAssertEqual(failure?.code, .unknown(rawValue: "test-error"))
    }

    func test_handle_whenFingerprintFailsWithTimeoutError_succeeds() async throws {
        // Given
        webSession.authenticateFromClosure = { _ in
            throw POFailure(code: .timeout(.mobile))
        }
        let customerAction = _CustomerAction(type: .fingerprint, value: "example.com")

        // When
        let value = try await sut.handle(
            action: customerAction, threeDSService: threeDSService, webAuthenticationCallback: nil
        )

            // Then
        let expectedValue = """
            gway_req_eyJib2R5IjoieyBcInRocmVlRFMyRmluZ2VycHJpbnRUaW1lb3V0XCI6IHRydWUgfSIsInVybCI6ImV4YW1wbGUuY29tIn0=
            """
        XCTAssertEqual(value, expectedValue)
    }

    func test_handle_whenFingerprintTakesTooLong_succeedsWithTimeout() async throws {
        // Given
        webSession.authenticateFromClosure = { _ in
            try await Task.sleep(seconds: 15)
            return URL(string: "test://return")!
        }
        let customerAction = _CustomerAction(type: .fingerprint, value: "example.com")

        // When
        let value = try await sut.handle(
            action: customerAction, threeDSService: threeDSService, webAuthenticationCallback: nil
        )

        // Then
        let expectedValue = """
            gway_req_eyJib2R5IjoieyBcInRocmVlRFMyRmluZ2VycHJpbnRUaW1lb3V0XCI6IHRydWUgfSIsInVybCI6ImV4YW1wbGUuY29tIn0=
            """
        XCTAssertEqual(value, expectedValue)
    }

    // MARK: - Private Properties

    private var sut: DefaultCustomerActionsService!

    private var threeDSService: Mock3DS2Service!
    private var webSession: MockWebAuthenticationSession!

    // MARK: - Private Methods

    private func defaultFingerprintMobileCustomerAction(padded: Bool = false) -> _CustomerAction {
        var value = """
            eyJkaXJlY3RvcnlTZXJ2ZXJJRCI6IjEiLCJkaXJlY3RvcnlTZXJ2ZXJQdWJsaWNLZXkiOiIyIiwiZGlyZWN0b3J5U2VydmVyUm9vd\
            ENBcyI6WyIzIl0sInRocmVlRFNTZXJ2ZXJUcmFuc0lEIjoiNCIsInNjaGVtZSI6IjUiLCJtZXNzYWdlVmVyc2lvbiI6IjYifQ
            """
        if padded {
            value += "=="
        }
        return _CustomerAction(type: .fingerprintMobile, value: value)
    }

    private var defaultChallengeMobileCustomerAction: _CustomerAction {
        let value = """
            eyJhY3NUcmFuc0lEIjoiMSIsImFjc1JlZmVyZW5jZU51bWJlciI6IjIiL\
            CJhY3NTaWduZWRDb250ZW50IjoiMyIsInRocmVlRFNTZXJ2ZXJUcmFuc0lEIjoiNCJ9
            """
        return _CustomerAction(type: .challengeMobile, value: value)
    }
}
