//
//  ThrottledWebAuthenticationSessionDecoratorTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2024.
//

@testable import ProcessOut
import XCTest

final class ThrottledWebAuthenticationSessionDecoratorTests: XCTestCase {

    // MARK: - Wait

    func test_authenticate_allowsOneAuthenticationAtTime() async throws {
        // Given
        let mockSession = MockWebAuthenticationSession()
        mockSession.authenticateFromClosure = { _ in
            try await Task.sleep(for: .seconds(5))
            return URL(string: "response.com")!
        }
        let sut = ThrottledWebAuthenticationSessionDecorator(session: mockSession)

        // When
        Task {
            _ = try await sut.authenticate(using: .init(url: URL(string: "request1.com")!, callback: nil))
        }
        Task {
            _ = try await sut.authenticate(using: .init(url: URL(string: "request2.com")!, callback: nil))
        }
        try await Task.sleep(for: .seconds(1))

        // Then
        XCTAssertEqual(mockSession.authenticateCallsCount, 1)
    }

    func test_authenticate_throttlesAuthentications() async throws {
        var lastAuthenticationStartTime: DispatchTime?

        // Given
        let mockSession = MockWebAuthenticationSession()
        mockSession.authenticateFromClosure = { _ in
            // Then
            if let lastAuthenticationStartTime {
                let delay = Int(DispatchTime.now().uptimeNanoseconds - lastAuthenticationStartTime.uptimeNanoseconds)
                let expectedDelay = 1_000_000_000, tolerance = 500_000_000 // 1 and 0.5 seconds respectfully
                XCTAssertTrue(abs(delay - expectedDelay) <= tolerance)
            }
            lastAuthenticationStartTime = DispatchTime.now()
            return URL(string: "response.com")!
        }
        let sut = ThrottledWebAuthenticationSessionDecorator(session: mockSession)

        // When
        _ = try await sut.authenticate(using: .init(url: URL(string: "request1.com")!, callback: nil))
        _ = try await sut.authenticate(using: .init(url: URL(string: "request2.com")!, callback: nil))
    }
}
