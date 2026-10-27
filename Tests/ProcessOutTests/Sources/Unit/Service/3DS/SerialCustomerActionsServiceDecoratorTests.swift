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
    func handle_runsHandlingsInOrder() async throws {
        // Given
        var handledValues: [String] = []
        let mockService = MockCustomerActionsService()
        mockService.handleFromClosure = { request, _ in
            handledValues.append(request.customerAction.value)
            try await Task.sleep(for: .milliseconds(200))
            return "response"
        }
        let sut = SerialCustomerActionsServiceDecorator(service: mockService)

        // When
        let values = ["request1", "request2", "request3"]
        var handlings: [Task<String, Error>] = []
        for value in values {
            handlings.append(
                Task { try await sut.handle(request: Self.request(value: value), threeDSService: Mock3DS2Service()) }
            )
            try await Task.sleep(for: .milliseconds(50))
        }
        for handling in handlings {
            _ = try await handling.value
        }

        // Then
        #expect(handledValues == values)
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
}
