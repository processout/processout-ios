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
        sut = DefaultCustomerActionsService(
            decoder: JSONDecoder(), encoder: encoder, jsonWritingOptions: [.sortedKeys]
        )
        threeDSService = Mock3DSService()
    }

    // MARK: - Fingerprint Mobile

    func test_handle_whenFingerprintMobileValueIsNotBase64EncodedConfiguration_fails() async {
        // Given
        let values = ["%", "{}", "e10="]

        for value in values {
            let customerAction = _CustomerAction(type: .fingerprintMobile, value: value)

            // When
            let handlingError = await assertThrowsError(
                try await sut.handle(action: customerAction, threeDSService: threeDSService)
            )

            // Then
            switch handlingError {
            case let failure as POFailure:
                XCTAssertEqual(failure.code, .internal(.mobile))
            default:
                XCTFail("Unexpected result")
            }
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
            scheme: .unknown("5"),
            messageVersion: "6"
        )
        var delegateCallsCount = 0

        for customerAction in customerActions {
            threeDSService.authenticationRequestFromClosure = { configuration, completion in
                // Then
                XCTAssertEqual(configuration, expectedConfiguration)
                delegateCallsCount += 1
                completion(.failure(.init(code: .generic(.mobile))))
            }

            // When
            _ = try? await sut.handle(action: customerAction, threeDSService: threeDSService)
        }
        XCTAssertEqual(delegateCallsCount, customerActions.count)
    }

    func test_handle_whenDelegateAuthenticationRequestFails_propagatesFailure() async {
        // Given
        let error = POFailure(code: .unknown(rawValue: "test-error"))
        threeDSService.authenticationRequestFromClosure = { _, completion in
            completion(.failure(error))
        }
        let customerAction = defaultFingerprintMobileCustomerAction()

        // When
        let handlingError = await assertThrowsError(
            try await sut.handle(action: customerAction, threeDSService: threeDSService)
        )

        // Then
        switch handlingError {
        case let failure as POFailure:
            XCTAssertEqual(failure.code, error.code)
        default:
            XCTFail("Unexpected result")
        }
    }

    func test_handle_whenAuthenticationRequestPublicKeyIsEmpty_fails() async {
        // Given
        var isDelegateCalled = false
        threeDSService.authenticationRequestFromClosure = { _, completion in
            let invalidAuthenticationRequest = PO3DS2AuthenticationRequest(
                deviceData: "", sdkAppId: "", sdkEphemeralPublicKey: "", sdkReferenceNumber: "", sdkTransactionId: ""
            )
            isDelegateCalled = true
            completion(.success(invalidAuthenticationRequest))
        }
        let customerAction = defaultFingerprintMobileCustomerAction()

        // When
        let error = await assertThrowsError(
            try await sut.handle(action: customerAction, threeDSService: threeDSService)
        )

        // Then
        switch error {
        case let failure as POFailure:
            XCTAssertEqual(failure.code, .internal(.mobile))
        default:
            XCTFail("Unexpected result")
        }
        XCTAssertTrue(isDelegateCalled)
    }

    func test_handle_whenAuthenticationRequestIsValid_succeeds() async throws {
        // Given
        let customerAction = defaultFingerprintMobileCustomerAction()
        threeDSService.authenticationRequestFromClosure = { _, completion in
            let authenticationRequest = PO3DS2AuthenticationRequest(
                deviceData: "1",
                sdkAppId: "2",
                sdkEphemeralPublicKey: #"{"kty": "EC"}"#,
                sdkReferenceNumber: "3",
                sdkTransactionId: "4"
            )
            completion(.success(authenticationRequest))
        }

        // When
        let token = try await sut.handle(action: customerAction, threeDSService: threeDSService)

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
        let error = await assertThrowsError(
            try await sut.handle(action: customerAction, threeDSService: threeDSService)
        )

        // Then
        switch error {
        case let failure as POFailure:
            XCTAssertEqual(failure.code, .internal(.mobile))
        default:
            XCTFail("Unexpected result")
        }
    }

    func test_handle_whenChallengeMobileValueIsValid_callsDelegateDoChallenge() async throws {
        // Given
        let expectedChallenge = PO3DS2Challenge(
            acsTransactionId: "1",
            acsReferenceNumber: "2",
            acsSignedContent: "3",
            threeDSServerTransactionId: "4"
        )
        var isDelegateCalled = false
        threeDSService.handleChallengeFromClosure = { challenge, completion in
            // Then
            XCTAssertEqual(challenge, expectedChallenge)
            isDelegateCalled = true
            completion(.success(true))
        }

        // When
        _ = try await sut.handle(action: defaultChallengeMobileCustomerAction, threeDSService: threeDSService)
        XCTAssertTrue(isDelegateCalled)
    }

    func test_handle_whenDelegateDoChallengeFails_propagatesFailure() async {
        // Given
        let error = POFailure(code: .unknown(rawValue: "test-error"))
        threeDSService.handleChallengeFromClosure = { _, completion in
            completion(.failure(error))
        }

        // When
        let handlingError = await assertThrowsError(
            try await sut.handle(action: defaultChallengeMobileCustomerAction, threeDSService: threeDSService)
        )

        // Then
        switch handlingError {
        case let failure as POFailure:
            XCTAssertEqual(failure.code, error.code)
        default:
            XCTFail("Unexpected result")
        }
    }

    func test_handle_whenDelegateDoChallengeCompletesWithTrue_succeeds() async throws {
        // Given
        threeDSService.handleChallengeFromClosure = { _, completion in
            completion(.success(true))
        }

        // When
        let token = try await sut.handle(action: defaultChallengeMobileCustomerAction, threeDSService: threeDSService)

        // Then
        XCTAssertEqual(token, "gway_req_eyJib2R5IjoieyBcInRyYW5zU3RhdHVzXCI6IFwiWVwiIH0ifQ==")
    }

    func test_handle_whenDelegateDoChallengeCompletesWithFalse_succeeds() async throws {
        // Given
        threeDSService.handleChallengeFromClosure = { _, completion in
            completion(.success(false))
        }

        // When
        let token = try await sut.handle(action: defaultChallengeMobileCustomerAction, threeDSService: threeDSService)

        // Then
        XCTAssertEqual(token, "gway_req_eyJib2R5IjoieyBcInRyYW5zU3RhdHVzXCI6IFwiTlwiIH0ifQ==")
    }

    // MARK: - Redirect

    func test_handle_whenActionTypeIsUrlOrFingerprint_callsDelegateRedirect() async throws {
        // Given
        var delegateCallsCount = 0
        threeDSService.handleRedirectFromClosure = { _, completion in
            // Then
            delegateCallsCount += 1
            completion(.success(""))
        }
        let actionTypes: [_CustomerAction.ActionType] = [.url, .fingerprint]

        for actionType in actionTypes {
            let customerAction = _CustomerAction(type: actionType, value: "example.com")

            // When
            _ = try await sut.handle(action: customerAction, threeDSService: threeDSService)
        }
        XCTAssertEqual(delegateCallsCount, actionTypes.count)
    }

    func test_handle_whenRedirectOrFingerprintValueIsNotValidUrl_fails() async {
        // Given
        let actionTypes: [_CustomerAction.ActionType] = [.redirect, .url, .fingerprint]

        for actionType in actionTypes {
            let action = _CustomerAction(type: actionType, value: "http://:-1")

            // When
            let error = await assertThrowsError(
                try await sut.handle(action: action, threeDSService: threeDSService)
            )

            // Then
            switch error {
            case let failure as POFailure:
                XCTAssertEqual(failure.code, .internal(.mobile))
            default:
                XCTFail("Unexpected result")
            }
        }
    }

    func test_handle_whenRedirectValueIsValidUrl_callsDelegateRedirect() async throws {
        // Given
        let expectedRedirect = PO3DSRedirect(
            url: URL(string: "example.com")!, timeout: nil
        )
        var isDelegateCalled = false
        threeDSService.handleRedirectFromClosure = { redirect, completion in
            // Then
            XCTAssertEqual(redirect, expectedRedirect)
            isDelegateCalled = true
            completion(.success(""))
        }
        let customerAction = _CustomerAction(type: .redirect, value: "example.com")

        // When
        _ = try await sut.handle(action: customerAction, threeDSService: threeDSService)
        XCTAssertTrue(isDelegateCalled)
    }

    func test_handle_whenRedirectCompletesWithNewToken_propagatesToken() async throws {
        // Given
        threeDSService.handleRedirectFromClosure = { _, completion in
            completion(.success("test"))
        }
        let customerAction = _CustomerAction(type: .redirect, value: "example.com")

        // When
        let value = try await sut.handle(action: customerAction, threeDSService: threeDSService)

        // Then
        XCTAssertEqual(value, "test")
    }

    func test_handle_whenRedirectFails_propagatesError() async {
        // Given
        threeDSService.handleRedirectFromClosure = { _, completion in
            let failure = POFailure(code: .unknown(rawValue: "test-error"))
            completion(.failure(failure))
        }
        let customerAction = _CustomerAction(type: .redirect, value: "example.com")

        // When
        let error = await assertThrowsError(
            try await sut.handle(action: customerAction, threeDSService: threeDSService)
        )

        // Then
        switch error {
        case let failure as POFailure:
            XCTAssertEqual(failure.code, .unknown(rawValue: "test-error"))
        default:
            XCTFail("Unexpected result")
        }
    }

    // MARK: - Fingerprint

    func test_handle_whenFingerprintValueIsValidUrl_callsDelegateRedirect() async throws {
        // Given
        let expectedRedirect = PO3DSRedirect(
            url: URL(string: "example.com")!, timeout: 10
        )
        var isDelegateCalled = false
        threeDSService.handleRedirectFromClosure = { redirect, completion in
            // Then
            XCTAssertEqual(redirect, expectedRedirect)
            isDelegateCalled = true
            completion(.success(""))
        }
        let customerAction = _CustomerAction(type: .fingerprint, value: "example.com")

        // When
        _ = try await sut.handle(action: customerAction, threeDSService: threeDSService)
        XCTAssertTrue(isDelegateCalled)
    }

    func test_handle_whenFingerprintCompletesWithNewToken_propagatesToken() async throws {
        // Given
        threeDSService.handleRedirectFromClosure = { _, completion in
            completion(.success("test"))
        }
        let customerAction = _CustomerAction(type: .fingerprint, value: "example.com")

        // When
        let value = try await sut.handle(action: customerAction, threeDSService: threeDSService)

        // Then
        XCTAssertEqual(value, "test")
    }

    func test_handle_whenFingerprintFails_propagatesError() async {
        // Given
        threeDSService.handleRedirectFromClosure = { _, completion in
            let failure = POFailure(code: .unknown(rawValue: "test-error"))
            completion(.failure(failure))
        }
        let customerAction = _CustomerAction(type: .fingerprint, value: "example.com")

        // When
        let error = await assertThrowsError(
            try await sut.handle(action: customerAction, threeDSService: threeDSService)
        )

        // Then
        switch error {
        case let failure as POFailure:
            XCTAssertEqual(failure.code, .unknown(rawValue: "test-error"))
        default:
            XCTFail("Unexpected result")
        }
    }

    func test_handle_whenFingerprintFailsWithTimeoutError_succeeds() async throws {
        // Given
        threeDSService.handleRedirectFromClosure = { _, completion in
            let failure = POFailure(code: .timeout(.mobile))
            completion(.failure(failure))
        }
        let customerAction = _CustomerAction(type: .fingerprint, value: "example.com")

        // When
        let value = try await sut.handle(action: customerAction, threeDSService: threeDSService)

            // Then
        let expectedValue = """
            gway_req_eyJib2R5IjoieyBcInRocmVlRFMyRmluZ2VycHJpbnRUaW1\
            lb3V0XCI6IHRydWUgfSIsInVybCI6ImV4YW1wbGUuY29tIn0=
            """
        XCTAssertEqual(value, expectedValue)
    }

    // MARK: - Private Properties

    private var threeDSService: Mock3DSService!
    private var sut: DefaultCustomerActionsService!

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
