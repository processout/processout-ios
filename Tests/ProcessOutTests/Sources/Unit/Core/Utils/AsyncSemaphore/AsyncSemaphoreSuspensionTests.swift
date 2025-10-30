//
//  AsyncSemaphoreSuspensionTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2024.
//

@testable import ProcessOut
import Testing

struct AsyncSemaphoreSuspensionTests {

    @Test
    func resume_whenStateIsNotSet_resumesContinuation() async {
        // Given
        let sut = AsyncSemaphoreSuspension()

        // When
        sut.resume()

        // Then
        await withUnsafeContinuation { sut.setContinuation($0) }
    }

    @Test
    func resume_whenAlreadyResumed_resumesContinuation() async {
        // Given
        let sut = AsyncSemaphoreSuspension()

        // When
        sut.resume()
        sut.resume()

        // Then
        await withUnsafeContinuation { sut.setContinuation($0) }
    }

    @Test
    func resume_whenContinuationIsSet_resumesContinuation() async {
        // Given
        let sut = AsyncSemaphoreSuspension()

        // When
        let task = Task {
            await withUnsafeContinuation { sut.setContinuation($0) }
        }
        sut.resume()

        // Then
        _ = await task.result
    }

    @Test
    func resume_whenStateIsNotSet_resumesThrowingContinuation() async throws {
        // Given
        let sut = AsyncSemaphoreSuspension()

        // When
        sut.resume()

        // Then
        try await withUnsafeThrowingContinuation { sut.setContinuation($0) }
    }

    @Test
    func resume_whenAlreadyResumed_resumesThrowingContinuation() async throws {
        // Given
        let sut = AsyncSemaphoreSuspension()

        // When
        sut.resume()
        sut.resume()

        // Then
        try await withUnsafeThrowingContinuation { sut.setContinuation($0) }
    }

    @Test
    func resume_whenContinuationIsSet_resumesThrowingContinuation() async {
        // Given
        let sut = AsyncSemaphoreSuspension()

        let task = Task {
            await #expect(throws: Never.self) {
                try await withUnsafeThrowingContinuation { sut.setContinuation($0) }
            }
        }

        // When
        sut.resume()
        _ = await task.result
    }

    @Test
    func cancel_whenStateIsNotSet_resumesContinuationWithError() async {
        // Given
        let sut = AsyncSemaphoreSuspension()

        // When
        sut.cancel()

        // Then
        await #expect(throws: CancellationError.self) {
            try await withUnsafeThrowingContinuation { sut.setContinuation($0) }
        }
    }

    @Test
    func cancel_whenAlreadyCancelled_resumesContinuationWithError() async {
        // Given
        let sut = AsyncSemaphoreSuspension()

        // When
        sut.cancel()
        sut.cancel()

        // Then
        await #expect(throws: CancellationError.self) {
            try await withUnsafeThrowingContinuation { sut.setContinuation($0) }
        }
    }

    @Test
    func cancel_whenContinuationIsSet_resumesContinuationWithError() async {
        // Given
        let sut = AsyncSemaphoreSuspension()

        // When
        let task = Task {
            await #expect(throws: CancellationError.self) {
                try await withUnsafeThrowingContinuation { sut.setContinuation($0) }
            }
        }
        sut.cancel()
        _ = await task.result
    }
}
