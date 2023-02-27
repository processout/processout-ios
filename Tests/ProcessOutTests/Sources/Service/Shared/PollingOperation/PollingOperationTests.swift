//
//  PollingOperationTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.02.2023.
//

import Foundation
import XCTest
@testable @_spi(PO) import ProcessOut

// swiftlint:disable implicitly_unwrapped_optional

final class PollingOperationTests: XCTestCase {

    func test_start_whenExecutingTooLong_failsWithTimeout() {
        var completionResult: Result<Void, POFailure>!
        let expectation = XCTestExpectation()

        // Given
        let sut = PollingOperation<Void>(
            timeout: 0.5,
            executeDelay: 0,
            execute: { _ in
                GroupCancellable()
            },
            shouldContinue: { _ in
                true
            },
            completion: { result in
                completionResult = result
                expectation.fulfill()
            }
        )

        // When
        sut.start()

        // Then
        wait(for: [expectation], timeout: 1)
        if case let .failure(failure) = completionResult, failure.code == .timeout(.mobile) {
            return
        }
        XCTFail("Unexpected result!")
    }

    func test_start_whenShouldntContinue_completesWithExecutionResult() {
        var completionResult: Result<String, POFailure>!
        let expectation = XCTestExpectation()

        // Given
        let expectedValue = UUID().uuidString
        let sut = PollingOperation<String>(
            timeout: 1,
            executeDelay: 0,
            execute: { completion in
                completion(.success(expectedValue))
                return GroupCancellable()
            },
            shouldContinue: { _ in
                false
            },
            completion: { result in
                completionResult = result
                expectation.fulfill()
            }
        )

        // When
        sut.start()

        // Then
        wait(for: [expectation], timeout: 1)
        if case .success(let value) = completionResult, value == expectedValue {
            return
        }
        XCTFail("Unexpected value!")
    }

    func test_cancel_whenExecuting_failsWithError() {
        var completionResult: Result<Void, POFailure>!

        // Given
        let sut = PollingOperation<Void>(
            timeout: 3,
            executeDelay: 0,
            execute: { _ in
                GroupCancellable()
            },
            shouldContinue: { _ in
                false
            },
            completion: { result in
                completionResult = result
            }
        )
        sut.start()

        // When
        sut.cancel()

        // Then
        if case let .failure(failure) = completionResult, failure.code == .cancelled {
            return
        }
        XCTFail("Unexpected result!")
    }

    func test_cancel_whenWaitingAfterExecution_failsWithError() {
        var completionResult: Result<Void, POFailure>!
        let expectation = XCTestExpectation()

        // Given
        let sut = PollingOperation<Void>(
            timeout: 1,
            executeDelay: 0.5,
            execute: { completion in
                completion(.success(()))
                return GroupCancellable()
            },
            shouldContinue: { _ in
                true
            },
            completion: { result in
                completionResult = result
                expectation.fulfill()
            }
        )
        sut.start()

        // When
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            sut.cancel()
        }

        // Then
        wait(for: [expectation], timeout: 1)
        if case let .failure(failure) = completionResult, failure.code == .cancelled {
            return
        }
        XCTFail("Unexpected result!")
    }

    func test_cancel_whenNotStarted_doesNothing() {
        var isAnyClosureCalled = false

        // Given
        let sut = PollingOperation<Void>(
            timeout: 0,
            executeDelay: 0,
            execute: { _ in
                isAnyClosureCalled = true
                return GroupCancellable()
            },
            shouldContinue: { _ in
                isAnyClosureCalled = true
                return true
            },
            completion: { _ in
                isAnyClosureCalled = true
            }
        )

        // When
        sut.cancel()

        // Then
        XCTAssert(!isAnyClosureCalled)
    }
}
