//
//  DefaultThreeDSServiceTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.04.2023.
//

import Foundation
import XCTest
@testable import ProcessOut

final class DefaultThreeDSServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        sut = DefaultThreeDSService(
            decoder: JSONDecoder(), encoder: encoder, jsonWritingOptions: [.sortedKeys], logger: POLogger()
        )
    }

    // MARK: - Fingerprint Mobile

    func test_handle_whenFingerprintMobileValueIsNotBase64EncodedConfiguration_complatesWithFailure() {
        // Given
        let delegate = Mock3DSService()
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
            directoryServerTransactionId: "3",
            messageVersion: "4"
        )
        let delegate = Mock3DSService()
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
        let delegate = Mock3DSService()
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
        let delegate = Mock3DSService()
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
        let delegate = Mock3DSService()
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
                // swiftlint:disable:next line_length
                let expectedToken = "gway_req_eyJib2R5Ijoie1wiZGV2aWNlQ2hhbm5lbFwiOlwiYXBwXCIsXCJzZGtBcHBJRFwiOlwiMlwiLFwic2RrRW5jRGF0YVwiOlwiMVwiLFwic2RrRXBoZW1QdWJLZXlcIjp7XCJrdHlcIjpcIkVDXCJ9LFwic2RrUmVmZXJlbmNlTnVtYmVyXCI6XCIzXCIsXCJzZGtUcmFuc0lEXCI6XCI0XCJ9In0="
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
        let delegate = Mock3DSService()
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

    // MARK: - Private Properties

    private var sut: DefaultThreeDSService!

    // MARK: - Private Methods

    private func defaultFingerprintMobileCustomerAction(padded: Bool = false) -> ThreeDSCustomerAction {
        // swiftlint:disable:next line_length
        var value = "eyJkaXJlY3RvcnlTZXJ2ZXJJRCI6IjEiLCJkaXJlY3RvcnlTZXJ2ZXJQdWJsaWNLZXkiOiIyIiwidGhyZWVEU1NlcnZlclRyYW5zSUQiOiIzIiwibWVzc2FnZVZlcnNpb24iOiI0In0"
        if padded {
            value += "="
        }
        return ThreeDSCustomerAction(type: .fingerprintMobile, value: value)
    }
}
