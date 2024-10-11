//
//  AsyncSemaphoreSuspensionTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2024.
//

@testable import ProcessOut
import XCTest

final class AsyncSemaphoreSuspensionTests: XCTestCase {

    func test_resume_whenStateIsNotSet_resumesContinuation() async {
        // Given
        let sut = AsyncSemaphoreSuspension()

        // When
        sut.resume()

        // Then
        await withUnsafeContinuation { sut.setContinuation($0) }
    }

    func test_resume_whenAlreadyResumed_resumesContinuation() async {
        // Given
        let sut = AsyncSemaphoreSuspension()

        // When
        sut.resume()
        sut.resume()

        // Then
        await withUnsafeContinuation { sut.setContinuation($0) }
    }

    func test_resume_whenContinuationIsSet_resumesContinuation() async {
        // Given
        let sut = AsyncSemaphoreSuspension()
        let expectation1 = XCTestExpectation(), expectation2 = XCTestExpectation()

        // When
        Task {
            await withUnsafeContinuation { continuation in
                sut.setContinuation(continuation)
                expectation1.fulfill()
            }
            expectation2.fulfill()
        }
        await fulfillment(of: [expectation1], timeout: 1)

        // Then
        sut.resume()
        await fulfillment(of: [expectation2], timeout: 1)
    }

    func test_resume_whenStateIsNotSet_resumesThrowingContinuation() async throws {
        // Given
        let sut = AsyncSemaphoreSuspension()

        // When
        sut.resume()

        // Then
        try await withUnsafeThrowingContinuation { sut.setContinuation($0) }
    }

    func test_resume_whenAlreadyResumed_resumesThrowingContinuation() async throws {
        // Given
        let sut = AsyncSemaphoreSuspension()

        // When
        sut.resume()
        sut.resume()

        // Then
        try await withUnsafeThrowingContinuation { sut.setContinuation($0) }
    }

    func test_resume_whenContinuationIsSet_resumesThrowingContinuation() async {
        // Given
        let sut = AsyncSemaphoreSuspension()
        let expectation1 = XCTestExpectation(), expectation2 = XCTestExpectation()

        // When
        Task {
            do {
                try await withUnsafeThrowingContinuation { continuation in
                    sut.setContinuation(continuation)
                    expectation1.fulfill()
                }
                expectation2.fulfill()
            } catch {
                XCTFail("Enexpected error.")
            }
        }
        await fulfillment(of: [expectation1], timeout: 1)

        // Then
        sut.resume()
        await fulfillment(of: [expectation2], timeout: 1)
    }

    func test_cancel_whenStateIsNotSet_resumesContinuationWithError() async {
        // Given
        let sut = AsyncSemaphoreSuspension()

        // When
        sut.cancel()

        // Then
        await assertThrowsError(
            try await withUnsafeThrowingContinuation { sut.setContinuation($0) }, errorType: CancellationError.self
        )
    }

    func test_cancel_whenAlreadyCancelled_resumesContinuationWithError() async {
        // Given
        let sut = AsyncSemaphoreSuspension()

        // When
        sut.cancel()
        sut.cancel()

        // Then
        await assertThrowsError(
            try await withUnsafeThrowingContinuation { sut.setContinuation($0) }, errorType: CancellationError.self
        )
    }

    func test_cancel_whenContinuationIsSet_resumesContinuationWithError() async {
        // Given
        let sut = AsyncSemaphoreSuspension()
        let expectation1 = XCTestExpectation(), expectation2 = XCTestExpectation()

        // When
        Task {
            do {
                try await withUnsafeThrowingContinuation { continuation in
                    sut.setContinuation(continuation)
                    expectation1.fulfill()
                }
            } catch {
                expectation2.fulfill()
            }
        }
        await fulfillment(of: [expectation1], timeout: 1)

        // Then
        sut.cancel()
        await fulfillment(of: [expectation2], timeout: 1)
    }
}
