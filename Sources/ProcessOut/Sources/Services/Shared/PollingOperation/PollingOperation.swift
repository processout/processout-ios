//
//  PollingOperation.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.02.2023.
//

import Foundation

final class PollingOperation<Value>: POCancellable {

    typealias Completion = (Result<Value, POFailure>) -> Void

    init(
        timeout: TimeInterval,
        executeDelay: TimeInterval,
        execute: @escaping (_ completion: @escaping Completion) -> POCancellable,
        shouldContinue: @escaping (Result<Value, POFailure>) -> Bool,
        completion: @escaping Completion
    ) {
        self.timeout = timeout
        self.executeDelay = executeDelay
        self.execute = execute
        self.shouldContinue = shouldContinue
        self.completion = completion
        state = .idle
    }

    func start() {
        guard case .idle = state else {
            return
        }
        let timer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [self] _ in
            let failure = POFailure(code: .timeout(.mobile))
            self.setCompletedState(result: .failure(failure))
        }
        let cancellable = GroupCancellable()
        let executingState = PollingOperationState.Executing(timeoutTimer: timer, cancellable: cancellable)
        state = .executing(executingState)
        cancellable.add(execute(attemptComplete))
    }

    func cancel() {
        let failure = POFailure(code: .cancelled)
        setCompletedState(result: .failure(failure))
    }

    // MARK: - Private Properties

    private let timeout: TimeInterval
    private let executeDelay: TimeInterval
    private let execute: (_ completion: @escaping Completion) -> POCancellable
    private let shouldContinue: (Result<Value, POFailure>) -> Bool
    private let completion: Completion
    private var state: PollingOperationState

    // MARK: - Private Methods

    private func setCompletedState(result: Result<Value, POFailure>) {
        switch state {
        case let .executing(executingState):
            state = .completed
            executingState.timeoutTimer.invalidate()
            executingState.cancellable.cancel()
        case let .waiting(waitingState):
            state = .completed
            waitingState.timeoutTimer.invalidate()
            waitingState.waitTimer.invalidate()
        default:
            return
        }
        completion(result)
    }

    private func attemptComplete(result: Result<Value, POFailure>) {
        guard case let .executing(executingState) = state else {
            return
        }
        if shouldContinue(result) {
            let timer = Timer.scheduledTimer(withTimeInterval: executeDelay, repeats: false) { [self] _ in
                guard case .waiting = state else {
                    return
                }
                let cancellable = GroupCancellable()
                let executingState = PollingOperationState.Executing(
                    timeoutTimer: executingState.timeoutTimer, cancellable: cancellable
                )
                state = .executing(executingState)
                cancellable.add(execute(attemptComplete))
            }
            let waitingState = PollingOperationState.Waiting(
                timeoutTimer: executingState.timeoutTimer, waitTimer: timer
            )
            state = .waiting(waitingState)
        } else {
            setCompletedState(result: result)
        }
    }
}
