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
        sut = DefaultThreeDSService(
            decoder: JSONDecoder(), encoder: encoder, jsonWritingOptions: [.sortedKeys], logger: POLogger.stub
        )
        delegate = Mock3DSService()
    }

    // MARK: - Fingerprint Mobile

    func test_handle_whenFingerprintMobileValueIsNotBase64EncodedConfiguration_fails() {
        // Given
        let values = ["%", "{}", "e10="]
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = values.count

        for value in values {
            let customerAction = ThreeDSCustomerAction(type: .fingerprintMobile, value: value)

            // When
            sut.handle(action: customerAction, delegate: delegate) { result in
                // Then
                switch result {
                case let .failure(failure):
                    XCTAssertEqual(failure.code, .internal(.mobile))
                default:
                    XCTFail("Unexpected result")
                }
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func test_handle_whenFingerprintMobileValueIsValid_callsDelegateAuthenticationRequest() {
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
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = customerActions.count

        for customerAction in customerActions {
            delegate.authenticationRequestFromClosure = { configuration, _ in
                // Then
                XCTAssertEqual(configuration, expectedConfiguration)
                expectation.fulfill()
            }

            // When
            sut.handle(action: customerAction, delegate: delegate) { _ in }
        }
        wait(for: [expectation], timeout: 1)
    }

    func test_handle_whenDelegateAuthenticationRequestFails_propagatesFailure() {
        // Given
        let error = POFailure(code: .unknown(rawValue: "test-error"))
        delegate.authenticationRequestFromClosure = { _, completion in
            completion(.failure(error))
        }
        let customerAction = defaultFingerprintMobileCustomerAction()
        let expectation = XCTestExpectation()

        // When
        sut.handle(action: customerAction, delegate: delegate) { result in
            // Then
            switch result {
            case .failure(let failure):
                XCTAssertEqual(failure.code, error.code)
            default:
                XCTFail("Unexpected result")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func test_handle_whenAuthenticationRequestPublicKeyIsEmpty_fails() {
        // Given
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2
        delegate.authenticationRequestFromClosure = { _, completion in
            let invalidAuthenticationRequest = PO3DS2AuthenticationRequest(
                deviceData: "", sdkAppId: "", sdkEphemeralPublicKey: "", sdkReferenceNumber: "", sdkTransactionId: ""
            )
            expectation.fulfill()
            completion(.success(invalidAuthenticationRequest))
        }
        let customerAction = defaultFingerprintMobileCustomerAction()

        // When
        sut.handle(action: customerAction, delegate: delegate) { result in
            // Then
            switch result {
            case .failure(let failure):
                XCTAssertEqual(failure.code, .internal(.mobile))
            default:
                XCTFail("Unexpected result")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func test_handle_whenAuthenticationRequestIsValid_succeeds() {
        // Given
        let customerAction = defaultFingerprintMobileCustomerAction()
        delegate.authenticationRequestFromClosure = { _, completion in
            let authenticationRequest = PO3DS2AuthenticationRequest(
                deviceData: "1",
                sdkAppId: "2",
                sdkEphemeralPublicKey: #"{"kty": "EC"}"#,
                sdkReferenceNumber: "3",
                sdkTransactionId: "4"
            )
            completion(.success(authenticationRequest))
        }
        let expectation = XCTestExpectation()

        // When
        sut.handle(action: customerAction, delegate: delegate) { result in
            // Then
            switch result {
            case .success(let token):
                let expectedToken = """
                    gway_req_eyJib2R5Ijoie1wiZGV2aWNlQ2hhbm5lbFwiOlwiYXBwXCIsXCJzZGtBcHBJRFwiOlwiMlwiLFwic2RrR\
                    W5jRGF0YVwiOlwiMVwiLFwic2RrRXBoZW1QdWJLZXlcIjp7XCJrdHlcIjpcIkVDXCJ9LFwic2RrUmVmZXJlbmNlTnV\
                    tYmVyXCI6XCIzXCIsXCJzZGtUcmFuc0lEXCI6XCI0XCJ9In0=
                    """
                XCTAssertEqual(token, expectedToken)
            default:
                XCTFail("Unexpected result")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func test_handle_whenDelegateCompletesOnBackground_completesOnMainThread() {
        // Given
        let customerAction = defaultFingerprintMobileCustomerAction()
        delegate.authenticationRequestFromClosure = { _, completion in
            let failure = POFailure(code: .cancelled)
            DispatchQueue.global().async {
                completion(.failure(failure))
            }
        }
        let expectation = XCTestExpectation()

        // When
        sut.handle(action: customerAction, delegate: delegate) { _ in
            // Then
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    // MARK: - Challenge Mobile

    func test_handle_whenChallengeMobileValueIsNotValid_fails() {
        // Given
        let expectation = XCTestExpectation()
        let customerAction = ThreeDSCustomerAction(type: .challengeMobile, value: "")

        // When
        sut.handle(action: customerAction, delegate: delegate) { result in
            // Then
            switch result {
            case let .failure(failure):
                XCTAssertEqual(failure.code, .internal(.mobile))
            default:
                XCTFail("Unexpected result")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func test_handle_whenChallengeMobileValueIsValid_callsDelegateDoChallenge() {
        // Given
        let expectedChallenge = PO3DS2Challenge(
            acsTransactionId: "1",
            acsReferenceNumber: "2",
            acsSignedContent: "3",
            threeDSServerTransactionId: "4"
        )
        let expectation = XCTestExpectation()
        delegate.handleChallengeFromClosure = { challenge, _ in
            // Then
            XCTAssertEqual(challenge, expectedChallenge)
            expectation.fulfill()
        }

        // When
        sut.handle(action: defaultChallengeMobileCustomerAction, delegate: delegate) { _ in }
        wait(for: [expectation], timeout: 1)
    }

    func test_handle_whenDelegateDoChallengeFails_propagatesFailure() {
        // Given
        let error = POFailure(code: .unknown(rawValue: "test-error"))
        delegate.handleChallengeFromClosure = { _, completion in
            completion(.failure(error))
        }
        let expectation = XCTestExpectation()

        // When
        sut.handle(action: defaultChallengeMobileCustomerAction, delegate: delegate) { result in
            // Then
            switch result {
            case .failure(let failure):
                XCTAssertEqual(failure.code, error.code)
            default:
                XCTFail("Unexpected result")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func test_handle_whenDelegateDoChallengeCompletesWithTrue_succeeds() {
        // Given
        delegate.handleChallengeFromClosure = { _, completion in
            completion(.success(true))
        }
        let expectation = XCTestExpectation()

        // When
        sut.handle(action: defaultChallengeMobileCustomerAction, delegate: delegate) { result in
            // Then
            switch result {
            case .success(let token):
                XCTAssertEqual(token, "gway_req_eyJib2R5IjoieyBcInRyYW5zU3RhdHVzXCI6IFwiWVwiIH0ifQ==")
            default:
                XCTFail("Unexpected result")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func test_handle_whenDelegateDoChallengeCompletesWithFalse_succeeds() {
        // Given
        delegate.handleChallengeFromClosure = { _, completion in
            completion(.success(false))
        }
        let expectation = XCTestExpectation()

        // When
        sut.handle(action: defaultChallengeMobileCustomerAction, delegate: delegate) { result in
            // Then
            switch result {
            case .success(let token):
                XCTAssertEqual(token, "gway_req_eyJib2R5IjoieyBcInRyYW5zU3RhdHVzXCI6IFwiTlwiIH0ifQ==")
            default:
                XCTFail("Unexpected result")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    // MARK: - Redirect

    func test_handle_whenActionTypeIsUrlOrFingerprint_callsDelegateRedirect() {
        // Given
        let expectation = XCTestExpectation()
        delegate.handleRedirectFromClosure = { _, _ in
            // Then
            expectation.fulfill()
        }
        let actionTypes: [ThreeDSCustomerAction.ActionType] = [.url, .fingerprint]
        expectation.expectedFulfillmentCount = actionTypes.count

        for actionType in actionTypes {
            let customerAction = ThreeDSCustomerAction(type: actionType, value: "example.com")

            // When
            sut.handle(action: customerAction, delegate: delegate) { _ in }
        }
        wait(for: [expectation], timeout: 1)
    }

    func test_handle_whenRedirectOrFingerprintValueIsNotValidUrl_fails() {
        // Given
        let expectation = XCTestExpectation()
        let actionTypes: [ThreeDSCustomerAction.ActionType] = [.redirect, .url, .fingerprint]
        expectation.expectedFulfillmentCount = actionTypes.count

        for actionType in actionTypes {
            let action = ThreeDSCustomerAction(type: actionType, value: " ")

            // When
            sut.handle(action: action, delegate: delegate) { result in
                // Then
                switch result {
                case let .failure(failure):
                    XCTAssertEqual(failure.code, .internal(.mobile))
                default:
                    XCTFail("Unexpected result")
                }
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func test_handle_whenRedirectValueIsValidUrl_callsDelegateRedirect() {
        // Given
        let expectedRedirect = PO3DSRedirect(
            url: URL(string: "example.com")!, timeout: nil
        )
        let expectation = XCTestExpectation()
        delegate.handleRedirectFromClosure = { redirect, _ in
            // Then
            XCTAssertEqual(redirect, expectedRedirect)
            expectation.fulfill()
        }
        let customerAction = ThreeDSCustomerAction(type: .redirect, value: "example.com")

        // When
        sut.handle(action: customerAction, delegate: delegate) { _ in }
        wait(for: [expectation], timeout: 1)
    }

    func test_handle_whenRedirectCompletesWithNewToken_propagatesToken() {
        // Given
        delegate.handleRedirectFromClosure = { _, completion in
            completion(.success("test"))
        }
        let expectation = XCTestExpectation()
        let customerAction = ThreeDSCustomerAction(type: .redirect, value: "example.com")

        // When
        sut.handle(action: customerAction, delegate: delegate) { result in
            // Then
            switch result {
            case .success(let value):
                XCTAssertEqual(value, "test")
            default:
                XCTFail("Unexpected result")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func test_handle_whenRedirectFails_propagatesError() {
        // Given
        delegate.handleRedirectFromClosure = { _, completion in
            let failure = POFailure(code: .unknown(rawValue: "test-error"))
            completion(.failure(failure))
        }
        let expectation = XCTestExpectation()
        let customerAction = ThreeDSCustomerAction(type: .redirect, value: "example.com")

        // When
        sut.handle(action: customerAction, delegate: delegate) { result in
            // Then
            switch result {
            case .failure(let failure):
                XCTAssertEqual(failure.code, .unknown(rawValue: "test-error"))
            default:
                XCTFail("Unexpected result")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    // MARK: - Fingerprint

    func test_handle_whenFingerprintValueIsValidUrl_callsDelegateRedirect() {
        // Given
        let expectedRedirect = PO3DSRedirect(
            url: URL(string: "example.com")!, timeout: 10
        )
        let expectation = XCTestExpectation()
        delegate.handleRedirectFromClosure = { redirect, _ in
            // Then
            XCTAssertEqual(redirect, expectedRedirect)
            expectation.fulfill()
        }
        let customerAction = ThreeDSCustomerAction(type: .fingerprint, value: "example.com")

        // When
        sut.handle(action: customerAction, delegate: delegate) { _ in }
        wait(for: [expectation], timeout: 1)
    }

    func test_handle_whenFingerprintCompletesWithNewToken_propagatesToken() {
        // Given
        delegate.handleRedirectFromClosure = { _, completion in
            completion(.success("test"))
        }
        let expectation = XCTestExpectation()
        let customerAction = ThreeDSCustomerAction(type: .fingerprint, value: "example.com")

        // When
        sut.handle(action: customerAction, delegate: delegate) { result in
            // Then
            switch result {
            case .success(let value):
                XCTAssertEqual(value, "test")
            default:
                XCTFail("Unexpected result")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func test_handle_whenFingerprintFails_propagatesError() {
        // Given
        delegate.handleRedirectFromClosure = { _, completion in
            let failure = POFailure(code: .unknown(rawValue: "test-error"))
            completion(.failure(failure))
        }
        let expectation = XCTestExpectation()
        let customerAction = ThreeDSCustomerAction(type: .fingerprint, value: "example.com")

        // When
        sut.handle(action: customerAction, delegate: delegate) { result in
            // Then
            switch result {
            case .failure(let failure):
                XCTAssertEqual(failure.code, .unknown(rawValue: "test-error"))
            default:
                XCTFail("Unexpected result")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func test_handle_whenFingerprintFailsWithTimeoutError_succeeds() {
        // Given
        delegate.handleRedirectFromClosure = { _, completion in
            let failure = POFailure(code: .timeout(.mobile))
            completion(.failure(failure))
        }
        let expectation = XCTestExpectation()
        let customerAction = ThreeDSCustomerAction(type: .fingerprint, value: "example.com")

        // When
        sut.handle(action: customerAction, delegate: delegate) { result in
            // Then
            switch result {
            case .success(let value):
                let expectedValue = """
                    gway_req_eyJib2R5IjoieyBcInRocmVlRFMyRmluZ2VycHJpbnRUaW1\
                    lb3V0XCI6IHRydWUgfSIsInVybCI6ImV4YW1wbGUuY29tIn0=
                    """
                XCTAssertEqual(value, expectedValue)
            default:
                XCTFail("Unexpected result")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    // MARK: - Private Properties

    private var delegate: Mock3DSService!
    private var sut: DefaultThreeDSService!

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
