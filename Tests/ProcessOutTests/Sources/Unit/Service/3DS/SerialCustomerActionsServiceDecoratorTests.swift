//
//  SerialCustomerActionsServiceDecoratorTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.10.2026.
//

import Foundation
import Testing
@testable @_spi(PO) import ProcessOut

struct SerialCustomerActionsServiceDecoratorTests {

    @Test
    func handle_allowsOneHandlingAtTime() async throws {
        // Given
        let mockService = MockCustomerActionsService()
        mockService.handleFromClosure = { _, _ in
            try await Task.sleep(for: .seconds(5))
            return "response"
        }
        let sut = SerialCustomerActionsServiceDecorator(service: mockService)

        // When
        _ = Task {
            _ = try await sut.handle(request: Self.request(value: "request1"), threeDSService: Mock3DS2Service())
        }
        _ = Task {
            _ = try await sut.handle(request: Self.request(value: "request2"), threeDSService: Mock3DS2Service())
        }
        try await Task.sleep(for: .milliseconds(500))

        // Then
        #expect(mockService.handleCallsCount == 1)
    }

    @Test
    func handle_runsHandlingsSerially() async throws {
        // Given
        let inFlightCounts = POUnfairlyLocked(wrappedValue: InFlightCounts())
        let mockService = MockCustomerActionsService()
        mockService.handleFromClosure = { _, _ in
            inFlightCounts.withLock { $0.increment() }
            try await Task.sleep(for: .milliseconds(200))
            inFlightCounts.withLock { $0.decrement() }
            return "response"
        }
        let sut = SerialCustomerActionsServiceDecorator(service: mockService)

        // When
        try await withThrowingTaskGroup(of: String.self) { group in
            for value in ["request1", "request2", "request3"] {
                group.addTask {
                    try await sut.handle(request: Self.request(value: value), threeDSService: Mock3DS2Service())
                }
            }
            try await group.waitForAll()
        }

        // Then
        #expect(inFlightCounts.wrappedValue.maximum == 1)
        #expect(mockService.handleCallsCount == 3)
    }

    @Test
    func handle_whenCancelledWhileQueued_failsWithoutHandling() async throws {
        // Given
        let mockService = MockCustomerActionsService()
        mockService.handleFromClosure = { _, _ in
            try await Task.sleep(for: .milliseconds(500))
            return "response"
        }
        let sut = SerialCustomerActionsServiceDecorator(service: mockService)
        let firstHandling = Task {
            try await sut.handle(request: Self.request(value: "request1"), threeDSService: Mock3DS2Service())
        }
        try await Task.sleep(for: .milliseconds(100))
        let secondHandling = Task {
            try await sut.handle(request: Self.request(value: "request2"), threeDSService: Mock3DS2Service())
        }
        try await Task.sleep(for: .milliseconds(100))

        // When
        secondHandling.cancel()
        let result = await secondHandling.result

        // Then
        guard case .failure(let error) = result else {
            Issue.record("Cancelled handling is expected to fail.")
            return
        }
        #expect((error as? POFailure)?.failureCode == .Mobile.cancelled)
        #expect(mockService.handleCallsCount == 1)
        _ = try await firstHandling.value
    }

    @Test
    func handle_whenPredecessorIsCancelled_handlesQueued() async throws {
        // Given
        let mockService = MockCustomerActionsService()
        mockService.handleFromClosure = { request, _ in
            if request.customerAction.value == "request1" {
                try await Task.sleep(for: .seconds(10))
            }
            return "response"
        }
        let sut = SerialCustomerActionsServiceDecorator(service: mockService)
        let firstHandling = Task {
            try await sut.handle(request: Self.request(value: "request1"), threeDSService: Mock3DS2Service())
        }
        try await Task.sleep(for: .milliseconds(100))
        let secondHandling = Task {
            try await sut.handle(request: Self.request(value: "request2"), threeDSService: Mock3DS2Service())
        }
        try await Task.sleep(for: .milliseconds(100))

        // When
        firstHandling.cancel()
        let firstResult = await firstHandling.result
        let secondResult = await secondHandling.result

        // Then
        guard case .failure = firstResult else {
            Issue.record("Cancelled handling is expected to fail.")
            return
        }
        #expect(try secondResult.get() == "response")
        #expect(mockService.handleCallsCount == 2)
    }

    // MARK: - Private Methods

    private static func request(value: String) -> CustomerActionRequest {
        .init(
            customerAction: _CustomerAction(type: .redirect, value: value),
            webAuthenticationCallback: nil,
            prefersEphemeralWebAuthenticationSession: true
        )
    }

    private struct InFlightCounts {

        private(set) var current = 0, maximum = 0

        mutating func increment() {
            current += 1
            maximum = max(maximum, current)
        }

        mutating func decrement() {
            current -= 1
        }
    }
}
