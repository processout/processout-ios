//
//  MockHttpConnector.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.11.2024.
//

@testable @_spi(PO) import ProcessOut

final class MockHttpConnector: HttpConnector {

    typealias Failure = HttpConnectorFailure

    var executeCallsCount: Int {
        lock.withLock { _executeCallsCount }
    }

    var executeFromClosure: ((Any) async throws -> Any)! {
        get { lock.withLock { _executeFromClosure } }
        set { lock.withLock { _executeFromClosure = newValue } }
    }

    // MARK: - HttpConnector

    func execute<Value>(
        request: HttpConnectorRequest<Value>
    ) async throws(HttpConnectorFailure) -> HttpConnectorResponse<Value> {
        let executeFromClosure = lock.withLock {
            _executeCallsCount += 1
            return _executeFromClosure
        }
        do {
            // swiftlint:disable:next force_cast
            return try await executeFromClosure!(request) as! HttpConnectorResponse<Value>
        } catch let failure as HttpConnectorFailure {
            throw failure
        } catch {
            throw HttpConnectorFailure(code: .internal, underlyingError: error)
        }
    }

    func replace(configuration: HttpConnectorConfiguration) {
        // Ignored
    }

    // MARK: - Private Properties

    private let lock = POUnfairlyLocked()

    private nonisolated(unsafe) var _executeCallsCount = 0
    private nonisolated(unsafe) var _executeFromClosure: ((Any) async throws -> Any)!
}
