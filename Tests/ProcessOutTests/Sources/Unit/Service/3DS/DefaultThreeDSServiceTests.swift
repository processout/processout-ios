//
//  DefaultThreeDSServiceTests.swift
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
        sut = DefaultThreeDSService(
            decoder: JSONDecoder(), encoder: encoder, jsonWritingOptions: [.sortedKeys], webSession: webSession
        )
        delegate = Mock3DSService()
    }

    // MARK: - Fingerprint Mobile

    func test_handle_whenFingerprintMobileValueIsNotBase64EncodedConfiguration_fails() async {
        // Given
        let values = ["%", "{}", "e10="]

        for value in values {
            let customerAction = ThreeDSCustomerAction(type: .fingerprintMobile, value: value)

            // When
            let failure = await assertThrowsError(
                try await sut.handle(action: customerAction, delegate: delegate), errorType: POFailure.self
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
            delegate.authenticationRequestParametersFromClosure = { configuration in
                // Then
                XCTAssertEqual(configuration, expectedConfiguration)
                delegateCallsCount += 1
                throw POFailure(code: .generic(.mobile))
            }

            // When
            _ = try? await sut.handle(action: customerAction, delegate: delegate)
        }
        XCTAssertEqual(delegateCallsCount, customerActions.count)
    }

    func test_handle_whenDelegateAuthenticationRequestFails_propagatesFailure() async {
        // Given
        let expectedError = POFailure(code: .unknown(rawValue: "test-error"))
        delegate.authenticationRequestParametersFromClosure = { _ in
            throw expectedError
        }
        let customerAction = defaultFingerprintMobileCustomerAction()

        // When
        let failure = await assertThrowsError(
            try await sut.handle(action: customerAction, delegate: delegate), errorType: POFailure.self
        )

        // Then
        XCTAssertEqual(failure?.code, expectedError.code)
    }

    func test_handle_whenAuthenticationRequestPublicKeyIsEmpty_fails() async {
        // Given
        var isDelegateCalled = false
        delegate.authenticationRequestParametersFromClosure = { _ in
            isDelegateCalled = true
            return .init(
                deviceData: "", sdkAppId: "", sdkEphemeralPublicKey: "", sdkReferenceNumber: "", sdkTransactionId: ""
            )
        }
        let customerAction = defaultFingerprintMobileCustomerAction()

        // When
        let failure = await assertThrowsError(
            try await sut.handle(action: customerAction, delegate: delegate), errorType: POFailure.self
        )

        // Then
        XCTAssertEqual(failure?.code, .internal(.mobile))
        XCTAssertTrue(isDelegateCalled)
    }

    func test_handle_whenAuthenticationRequestIsValid_succeeds() async throws {
        // Given
        let customerAction = defaultFingerprintMobileCustomerAction()
        delegate.authenticationRequestParametersFromClosure = { _ in
            PO3DS2AuthenticationRequestParameters(
                deviceData: "1",
                sdkAppId: "2",
                sdkEphemeralPublicKey: #"{"kty": "EC"}"#,
                sdkReferenceNumber: "3",
                sdkTransactionId: "4"
            )
        }

        // When
        let token = try await sut.handle(action: customerAction, delegate: delegate)

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
        let customerAction = ThreeDSCustomerAction(type: .challengeMobile, value: "")

        // When
        let failure = await assertThrowsError(
            try await sut.handle(action: customerAction, delegate: delegate), errorType: POFailure.self
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
        delegate.performChallengeFromClosure = { challenge in
            // Then
            XCTAssertEqual(challenge, expectedChallenge)
            isDelegateCalled = true
            return .init(transactionStatus: "Y")
        }

        // When
        _ = try await sut.handle(action: defaultChallengeMobileCustomerAction, delegate: delegate)
        XCTAssertTrue(isDelegateCalled)
    }

    func test_handle_whenDelegateDoChallengeFails_propagatesFailure() async {
        // Given
        let expectedError = POFailure(code: .unknown(rawValue: "test-error"))
        delegate.performChallengeFromClosure = { _ in
            throw expectedError
        }

        // When
        let failure = await assertThrowsError(
            try await sut.handle(action: defaultChallengeMobileCustomerAction, delegate: delegate),
            errorType: POFailure.self
        )

        // Then
        XCTAssertEqual(failure?.code, expectedError.code)
    }

    func test_handle_whenDelegateDoChallengeCompletesWithTrue_succeeds() async throws {
        // Given
        delegate.performChallengeFromClosure = { _ in
            .init(transactionStatus: "Y")
        }

        // When
        let token = try await sut.handle(action: defaultChallengeMobileCustomerAction, delegate: delegate)

        // Then
        XCTAssertEqual(token, "gway_req_eyJib2R5Ijoie1widHJhbnNTdGF0dXNcIjpcIllcIn0ifQ==")
    }

    func test_handle_whenDelegateDoChallengeCompletesWithFalse_succeeds() async throws {
        // Given
        delegate.performChallengeFromClosure = { _ in
            .init(transactionStatus: "N")
        }

        // When
        let token = try await sut.handle(action: defaultChallengeMobileCustomerAction, delegate: delegate)

        // Then
        XCTAssertEqual(token, "gway_req_eyJib2R5Ijoie1widHJhbnNTdGF0dXNcIjpcIk5cIn0ifQ==")
    }

    // MARK: - Redirect

    func test_handle_whenActionTypeIsUrlOrFingerprint_callsWebSession() async throws {
        // Given
        webSession.authenticateFromClosure = { _, _, _ in
            URL(string: "example.com")!
        }
        let actionTypes: [ThreeDSCustomerAction.ActionType] = [.url, .fingerprint]

        for actionType in actionTypes {
            let customerAction = ThreeDSCustomerAction(type: actionType, value: "example.com")

            // When
            _ = try await sut.handle(action: customerAction, delegate: delegate)
        }

        // Then
        XCTAssertEqual(webSession.authenticateCallsCount, actionTypes.count)
    }

    func test_handle_whenRedirectOrFingerprintValueIsNotValidUrl_fails() async {
        // Given
        let actionTypes: [ThreeDSCustomerAction.ActionType] = [.redirect, .url, .fingerprint]

        for actionType in actionTypes {
            let action = ThreeDSCustomerAction(type: actionType, value: "")

            // When
            let failure = await assertThrowsError(
                try await sut.handle(action: action, delegate: delegate), errorType: POFailure.self
            )

            // Then
            XCTAssertEqual(failure?.code, .internal(.mobile))
        }
    }

    func test_handle_whenRedirectValueIsValidUrl_callsWebSession() async throws {
        // Given
        webSession.authenticateFromClosure = { url, _, _ in
            XCTAssertEqual(URL(string: "example.com"), url)
            return URL(string: "test://return")!
        }
        let customerAction = ThreeDSCustomerAction(type: .redirect, value: "example.com")

        // When
        _ = try await sut.handle(action: customerAction, delegate: delegate)
        XCTAssertEqual(webSession.authenticateCallsCount, 1)
    }

    func test_handle_whenRedirectCompletesWithNewToken_propagatesToken() async throws {
        // Given
        webSession.authenticateFromClosure = { _, _, _ in
            URL(string: "test://return?token=test")!
        }
        let customerAction = ThreeDSCustomerAction(type: .redirect, value: "example.com")

        // When
        let value = try await sut.handle(action: customerAction, delegate: delegate)

        // Then
        XCTAssertEqual(value, "test")
    }

    func test_handle_whenRedirectFails_propagatesError() async {
        // Given
        webSession.authenticateFromClosure = { _, _, _ in
            throw POFailure(code: .unknown(rawValue: "test-error"))
        }

        let customerAction = ThreeDSCustomerAction(type: .redirect, value: "example.com")

        // When
        let failure = await assertThrowsError(
            try await sut.handle(action: customerAction, delegate: delegate), errorType: POFailure.self
        )

        // Then
        XCTAssertEqual(failure?.code, .unknown(rawValue: "test-error"))
    }

    // MARK: - Fingerprint

    func test_handle_whenFingerprintValueIsValidUrl_callsWebSession() async throws {
        // Given
        let expectedRedirectUrl = URL(string: "example.com")!
        webSession.authenticateFromClosure = { url, _, _ in
            XCTAssertEqual(url, expectedRedirectUrl)
            return URL(string: "test://return")!
        }
        let customerAction = ThreeDSCustomerAction(type: .fingerprint, value: expectedRedirectUrl.absoluteString)

        // When
        _ = try await sut.handle(action: customerAction, delegate: delegate)
        XCTAssertEqual(webSession.authenticateCallsCount, 1)
    }

    func test_handle_whenFingerprintCompletesWithNewToken_propagatesToken() async throws {
        // Given
        webSession.authenticateFromClosure = { _, _, _ in
            URL(string: "test://return?token=test")!
        }
        let customerAction = ThreeDSCustomerAction(type: .fingerprint, value: "example.com")

        // When
        let value = try await sut.handle(action: customerAction, delegate: delegate)

        // Then
        XCTAssertEqual(value, "test")
    }

    func test_handle_whenFingerprintFails_propagatesError() async {
        // Given
        webSession.authenticateFromClosure = { _, _, _ in
            throw POFailure(code: .unknown(rawValue: "test-error"))
        }
        let customerAction = ThreeDSCustomerAction(type: .fingerprint, value: "example.com")

        // When
        let failure = await assertThrowsError(
            try await sut.handle(action: customerAction, delegate: delegate), errorType: POFailure.self
        )

        // Then
        XCTAssertEqual(failure?.code, .unknown(rawValue: "test-error"))
    }

    func test_handle_whenFingerprintFailsWithTimeoutError_succeeds() async throws {
        // Given
        webSession.authenticateFromClosure = { _, _, _ in
            throw POFailure(code: .timeout(.mobile))
        }
        let customerAction = ThreeDSCustomerAction(type: .fingerprint, value: "example.com")

        // When
        let value = try await sut.handle(action: customerAction, delegate: delegate)

            // Then
        let expectedValue = """
            gway_req_eyJib2R5IjoieyBcInRocmVlRFMyRmluZ2VycHJpbnRUaW1lb3V0XCI6IHRydWUgfSIsInVybCI6ImV4YW1wbGUuY29tIn0=
            """
        XCTAssertEqual(value, expectedValue)
    }

    func test_handle_whenFingerprintTakesTooLong_succeedsWithTimeout() async throws {
        // Given
        webSession.authenticateFromClosure = { _, _, _ in
            try await Task.sleep(seconds: 15)
            return URL(string: "test://return")!
        }
        let customerAction = ThreeDSCustomerAction(type: .fingerprint, value: "example.com")

        // When
        let value = try await sut.handle(action: customerAction, delegate: delegate)

        // Then
        let expectedValue = """
            gway_req_eyJib2R5IjoieyBcInRocmVlRFMyRmluZ2VycHJpbnRUaW1lb3V0XCI6IHRydWUgfSIsInVybCI6ImV4YW1wbGUuY29tIn0=
            """
        XCTAssertEqual(value, expectedValue)
    }

    // MARK: - Private Properties

    private var sut: DefaultThreeDSService!

    private var delegate: Mock3DSService!
    private var webSession: MockWebAuthenticationSession!

    // MARK: - Private Methods

    private func defaultFingerprintMobileCustomerAction(padded: Bool = false) -> ThreeDSCustomerAction {
        var value = """
            eyJkaXJlY3RvcnlTZXJ2ZXJJRCI6IjEiLCJkaXJlY3RvcnlTZXJ2ZXJQdWJsaWNLZXkiOiIyIiwiZGlyZWN0b3J5U2VydmVyUm9vd\
            ENBcyI6WyIzIl0sInRocmVlRFNTZXJ2ZXJUcmFuc0lEIjoiNCIsInNjaGVtZSI6IjUiLCJtZXNzYWdlVmVyc2lvbiI6IjYifQ
            """
        if padded {
            value += "=="
        }
        return ThreeDSCustomerAction(type: .fingerprintMobile, value: value)
    }

    private var defaultChallengeMobileCustomerAction: ThreeDSCustomerAction {
        let value = """
            eyJhY3NUcmFuc0lEIjoiMSIsImFjc1JlZmVyZW5jZU51bWJlciI6IjIiL\
            CJhY3NTaWduZWRDb250ZW50IjoiMyIsInRocmVlRFNTZXJ2ZXJUcmFuc0lEIjoiNCJ9
            """
        return ThreeDSCustomerAction(type: .challengeMobile, value: value)
    }
}
