//
//  ThrottledWebAuthenticationSessionDecoratorTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2024.
//

import Foundation
import Testing
@testable @_spi(PO) import ProcessOut

struct ThrottledWebAuthenticationSessionDecoratorTests {

    // MARK: - Wait

    @Test
    func authenticate_allowsOneAuthenticationAtTime() async throws {
        // Given
        let mockSession = MockWebAuthenticationSession()
        mockSession.authenticateFromClosure = { _ in
            try await Task.sleep(for: .seconds(5))
            return URL(string: "response.com")!
        }
        let sut = ThrottledWebAuthenticationSessionDecorator(session: mockSession)

        // When
        Task {
            _ = try await sut.authenticate(
                using: .init(url: URL(string: "request1.com")!, callback: nil, prefersEphemeralSession: true)
            )
        }
        Task {
            _ = try await sut.authenticate(
                using: .init(url: URL(string: "request2.com")!, callback: nil, prefersEphemeralSession: true)
            )
        }
        try await Task.sleep(for: .seconds(1))

        // Then
        #expect(mockSession.authenticateCallsCount == 1)
    }

    @Test(.disabled("Flaky"))
    func authenticate_throttlesAuthentications() async throws {
        var lastAuthenticationStartTime: DispatchTime?

        // Given
        let mockSession = MockWebAuthenticationSession()
        mockSession.authenticateFromClosure = { _ in
            // Then
            if let lastAuthenticationStartTime {
                let delay = DispatchTime.now().uptimeSeconds - lastAuthenticationStartTime.uptimeSeconds
                let expectedDelay: TimeInterval = 1, tolerance: TimeInterval = 0.5
                #expect(abs(delay - expectedDelay) <= tolerance)
            }
            lastAuthenticationStartTime = DispatchTime.now()
            return URL(string: "response.com")!
        }
        let sut = ThrottledWebAuthenticationSessionDecorator(session: mockSession)

        // When
        _ = try await sut.authenticate(
            using: .init(url: URL(string: "request1.com")!, callback: nil, prefersEphemeralSession: true)
        )
        _ = try await sut.authenticate(
            using: .init(url: URL(string: "request2.com")!, callback: nil, prefersEphemeralSession: true)
        )
    }
}
