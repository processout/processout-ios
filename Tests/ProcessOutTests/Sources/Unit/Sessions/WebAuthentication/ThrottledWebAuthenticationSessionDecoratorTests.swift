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
        _ = Task {
            _ = try await sut.authenticate(using: Self.request(url: "request1.com"))
        }
        _ = Task {
            _ = try await sut.authenticate(using: Self.request(url: "request2.com"))
        }
        try await Task.sleep(for: .seconds(1))

        // Then
        #expect(mockSession.authenticateCallsCount == 1)
    }

    @Test
    func authenticate_runsAuthenticationsInOrder() async throws {
        // Given
        var authenticatedUrls: [URL] = []
        let mockSession = MockWebAuthenticationSession()
        mockSession.authenticateFromClosure = { request in
            authenticatedUrls.append(request.url)
            try await Task.sleep(for: .milliseconds(200))
            return URL(string: "response.com")!
        }
        let sut = ThrottledWebAuthenticationSessionDecorator(session: mockSession)

        // When
        let urls = ["request1.com", "request2.com", "request3.com"]
        var authentications: [Task<URL, Error>] = []
        for url in urls {
            authentications.append(
                Task { try await sut.authenticate(using: Self.request(url: url)) }
            )
            try await Task.sleep(for: .milliseconds(50))
        }
        for authentication in authentications {
            _ = try await authentication.value
        }

        // Then
        #expect(authenticatedUrls == urls.map { URL(string: $0)! })
    }

    @Test
    func authenticate_whenCancelledWhileQueued_failsWithoutAuthenticating() async throws {
        // Given
        let mockSession = MockWebAuthenticationSession()
        mockSession.authenticateFromClosure = { _ in
            try await Task.sleep(for: .seconds(1))
            return URL(string: "response.com")!
        }
        let sut = ThrottledWebAuthenticationSessionDecorator(session: mockSession)
        let firstAuthentication = Task {
            try await sut.authenticate(using: Self.request(url: "request1.com"))
        }
        try await Task.sleep(for: .milliseconds(100))
        let secondAuthentication = Task {
            try await sut.authenticate(using: Self.request(url: "request2.com"))
        }
        try await Task.sleep(for: .milliseconds(100))

        // When
        secondAuthentication.cancel()
        let result = await secondAuthentication.result

        // Then
        guard case .failure(let error) = result else {
            Issue.record("Cancelled authentication is expected to fail.")
            return
        }
        #expect((error as? POFailure)?.failureCode == .Mobile.cancelled)
        #expect(mockSession.authenticateCallsCount == 1)
        _ = try await firstAuthentication.value
    }

    @Test
    func authenticate_whenPredecessorIsCancelled_authenticatesQueued() async throws {
        // Given
        let mockSession = MockWebAuthenticationSession()
        mockSession.authenticateFromClosure = { request in
            if request.url.absoluteString == "request1.com" {
                try await Task.sleep(for: .seconds(10))
            }
            return URL(string: "response.com")!
        }
        let sut = ThrottledWebAuthenticationSessionDecorator(session: mockSession)
        let firstAuthentication = Task {
            try await sut.authenticate(using: Self.request(url: "request1.com"))
        }
        try await Task.sleep(for: .milliseconds(100))
        let secondAuthentication = Task {
            try await sut.authenticate(using: Self.request(url: "request2.com"))
        }
        try await Task.sleep(for: .milliseconds(100))

        // When
        firstAuthentication.cancel()
        let firstResult = await firstAuthentication.result
        let secondResult = await secondAuthentication.result

        // Then
        guard case .failure = firstResult else {
            Issue.record("Cancelled authentication is expected to fail.")
            return
        }
        #expect(try secondResult.get() == URL(string: "response.com")!)
        #expect(mockSession.authenticateCallsCount == 2)
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
        _ = try await sut.authenticate(using: Self.request(url: "request1.com"))
        _ = try await sut.authenticate(using: Self.request(url: "request2.com"))
    }

    // MARK: - Private Methods

    private static func request(url: String) -> POWebAuthenticationRequest {
        .init(url: URL(string: url)!, callback: nil, prefersEphemeralSession: true)
    }
}
