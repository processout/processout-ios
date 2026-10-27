//
//  MockCustomerActionsService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.10.2026.
//

import Foundation
@testable @_spi(PO) import ProcessOut

final class MockCustomerActionsService: CustomerActionsService {

    var handleCallsCount: Int {
        lock.withLock { _handleCallsCount }
    }

    var handleFromClosure: ((CustomerActionRequest, PO3DS2Service) async throws -> String)! {
        get { lock.withLock { _handleFromClosure } }
        set { lock.withLock { _handleFromClosure = newValue } }
    }

    // MARK: - CustomerActionsService

    func handle(request: CustomerActionRequest, threeDSService: PO3DS2Service) async throws -> String {
        let handle = lock.withLock {
            _handleCallsCount += 1
            return _handleFromClosure
        }
        return try await handle!(request, threeDSService)
    }

    // MARK: - Private Properties

    private let lock = POUnfairlyLocked()

    private nonisolated(unsafe) var _handleCallsCount = 0
    private nonisolated(unsafe) var _handleFromClosure: ((CustomerActionRequest, PO3DS2Service) async throws -> String)!
}
