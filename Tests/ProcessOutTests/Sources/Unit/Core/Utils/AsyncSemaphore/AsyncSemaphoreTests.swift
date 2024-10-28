//
//  AsyncSemaphoreTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2024.
//

@testable @_spi(PO) import ProcessOut
import XCTest

final class AsyncSemaphoreTests: XCTestCase {

    // MARK: - Wait

    func test_wait_whenInitialValueIsZero_suspends() async {
        // Given
        let sut = POAsyncSemaphore(value: 0)
        let expectation = XCTestExpectation()
        expectation.isInverted = true

        // When
        Task {
            await sut.wait()
            expectation.fulfill()
        }

        // Then
        await fulfillment(of: [expectation], timeout: 1)
    }

    func test_wait_whenInitialValueIsGreaterThanZero_doesntSuspend() async {
        // Given
        let sut = POAsyncSemaphore(value: 1)
        let expectation = XCTestExpectation()

        // When
        Task {
            await sut.wait()
            expectation.fulfill()
        }

        // Then
        await fulfillment(of: [expectation], timeout: 1)
    }

    func test_wait_whenSemaphoreIsBlocked_suspendsSecondFunc() async {
        // Given
        let sut = POAsyncSemaphore(value: 1)
        let expectation1 = XCTestExpectation(), expectation2 = XCTestExpectation()
        expectation2.isInverted = true

        // When
        Task {
            await sut.wait()
            expectation1.fulfill()
            await sut.wait()
            expectation2.fulfill()
        }

        // Then
        await fulfillment(of: [expectation1, expectation2], timeout: 1)
    }

    // MARK: - Wait Unless Cancelled

    func test_waitUnlessCancelled_whenInitialValueIsZero_suspendsAndDoesntThrow() async {
        // Given
        let sut = POAsyncSemaphore(value: 0)
        let expectation = XCTestExpectation()
        expectation.isInverted = true

        // When
        Task {
            do {
                try await sut.waitUnlessCancelled()
                expectation.fulfill()
            } catch {
                XCTFail("Unexpected error.")
            }
        }

        // Then
        await fulfillment(of: [expectation], timeout: 1)
    }

    func test_waitUnlessCancelled_whenInitialValueIsGreaterThanZero_doesntSuspendNorThrow() async {
        // Given
        let sut = POAsyncSemaphore(value: 1)
        let expectation = XCTestExpectation()

        // When
        Task {
            do {
                try await sut.waitUnlessCancelled()
                expectation.fulfill()
            } catch {
                XCTFail("Unexpected error.")
            }
        }

        // Then
        await fulfillment(of: [expectation], timeout: 1)
    }

    func test_waitUnlessCancelled_whenSemaphoreIsBlocked_suspendsSecondFuncAndDoesntThrow() async {
        // Given
        let sut = POAsyncSemaphore(value: 1)
        let expectation1 = XCTestExpectation(), expectation2 = XCTestExpectation()
        expectation2.isInverted = true

        // When
        Task {
            do {
                try await sut.waitUnlessCancelled()
                expectation1.fulfill()
                try await sut.waitUnlessCancelled()
                expectation2.fulfill()
            } catch {
                XCTFail("Unexpected error.")
            }
        }

        // Then
        await fulfillment(of: [expectation1, expectation2], timeout: 1)
    }

    func test_waitUnlessCancelled_whenCancelledImmediately_throwsCancellationError() async {
        // Given
        let sut = POAsyncSemaphore(value: 0)
        let expectation = XCTestExpectation()

        // When
        let task = Task {
            do {
                try await sut.waitUnlessCancelled()
            } catch {
                XCTAssertTrue(error is CancellationError)
                expectation.fulfill()
            }
        }
        task.cancel()

        // Then
        await fulfillment(of: [expectation], timeout: 1)
    }

    func test_waitUnlessCancelled_whenCancelledAfterDelay_throwsCancellationError() async {
        // Given
        let sut = POAsyncSemaphore(value: 0)
        let expectation = XCTestExpectation()

        // When
        let task = Task {
            do {
                try await sut.waitUnlessCancelled()
            } catch {
                XCTAssertTrue(error is CancellationError)
                expectation.fulfill()
            }
        }
        Task {
            try await Task.sleep(for: .seconds(0.5))
            task.cancel()
        }

        // Then
        await fulfillment(of: [expectation], timeout: 2)
    }

    // MARK: - Signal

    func test_signal_whenSemaphoreIsBlocked_resumesWhenSignalled() async {
        // Given
        let sut = POAsyncSemaphore(value: 1)
        let expectation = XCTestExpectation()

        // When
        Task {
            await sut.wait()
            sut.signal()
            await sut.wait()
            expectation.fulfill()
        }

        // Then
        await fulfillment(of: [expectation], timeout: 1)
    }
}
