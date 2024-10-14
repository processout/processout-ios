//
//  AsyncSemaphoreSuspension.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2024.
//

import Foundation

final class AsyncSemaphoreSuspension: Sendable {

    func resume() {
        state.withLock { state in
            switch state {
            case .suspendedUnlessCancelled(let unsafeContinuation):
                state = .resumed
                unsafeContinuation.resume()
            case .suspended(let unsafeContinuation):
                state = .resumed
                unsafeContinuation.resume()
            case .cancelled:
                assertionFailure("Cannot resume a canceled suspension.")
            case .resumed:
                break
            case nil:
                state = .resumed
            }
        }
    }

    func cancel() {
        state.withLock { state in
            switch state {
            case .suspendedUnlessCancelled(let unsafeContinuation):
                state = .cancelled
                unsafeContinuation.resume(throwing: CancellationError())
            case .suspended:
                assertionFailure("Cancellation attempted on a continuation that does not support it.")
            case .cancelled:
                break
            case .resumed:
                assertionFailure("Cannot cancel a suspension that has already been resumed.")
            case nil:
                state = .cancelled
            }
        }
    }

    @discardableResult
    func setContinuation(_ unsafeContinuation: UnsafeContinuation<Void, Error>) -> Bool {
        state.withLock { state in
            switch state {
            case .suspendedUnlessCancelled, .suspended:
                preconditionFailure("The continuation is already established.")
            case .cancelled:
                unsafeContinuation.resume(throwing: CancellationError())
            case .resumed:
                unsafeContinuation.resume()
            case nil:
                state = .suspendedUnlessCancelled(unsafeContinuation)
                return true
            }
            return false
        }
    }

    @discardableResult
    func setContinuation(_ unsafeContinuation: UnsafeContinuation<Void, Never>) -> Bool {
        state.withLock { state in
            switch state {
            case .suspendedUnlessCancelled, .suspended:
                preconditionFailure("The continuation is already established.")
            case .cancelled:
                preconditionFailure(
                    "The suspension was canceled, but provided continuation doesn't support cancellation."
                )
            case .resumed:
                unsafeContinuation.resume()
            case nil:
                state = .suspended(unsafeContinuation)
                return true
            }
            return false
        }
    }

    // MARK: - Private Nested Types

    private enum State {

        /// Waiting for a signal, with support for cancellation.
        case suspendedUnlessCancelled(UnsafeContinuation<Void, Error>)

        /// Waiting for a signal, with no support for cancellation.
        case suspended(UnsafeContinuation<Void, Never>)

        /// Cancelled before we have started waiting.
        case cancelled

        /// Suspension is already resumed.
        case resumed
    }

    // MARK: - Private Properties

    private let state = POUnfairlyLocked<State?>(wrappedValue: nil)
}
