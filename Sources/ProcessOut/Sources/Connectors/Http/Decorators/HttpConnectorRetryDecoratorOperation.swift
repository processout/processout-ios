//
//  HttpConnectorRetryDecoratorOperation.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.02.2023.
//

import Foundation

final class HttpConnectorRetryDecoratorOperation<Value: Decodable>: POCancellableType {

    init(
        connector: HttpConnectorType,
        retryStrategy: RetryStrategy,
        request: HttpConnectorRequest<Value>,
        completion: @escaping (Result<Value, HttpConnectorFailure>) -> Void
    ) {
        self.connector = connector
        self.retryStrategy = retryStrategy
        self.request = request
        self.completion = completion
        state = .idle
    }

    func start() {
        guard case .idle = state else {
            return
        }
        let cancellable = GroupCancellable()
        let executingState = HttpConnectorRetryDecoratorOperationState.Executing(
            cancellable: cancellable, retryCount: 0
        )
        state = .executing(executingState)
        cancellable.add(connector.execute(request: request, completion: attemptComplete))
    }

    func cancel() {
        setCompletedState(result: .failure(.cancelled))
    }

    // MARK: - Private Nested Types

    private let connector: HttpConnectorType
    private let retryStrategy: RetryStrategy
    private let request: HttpConnectorRequest<Value>
    private let completion: (Result<Value, HttpConnectorFailure>) -> Void
    private var state: HttpConnectorRetryDecoratorOperationState

    // MARK: - Private Methods

    private func setCompletedState(result: Result<Value, HttpConnectorFailure>) {
        switch state {
        case let .executing(executingState):
            state = .completed
            executingState.cancellable.cancel()
        case let .waiting(timer):
            state = .completed
            timer.invalidate()
        default:
            return
        }
        completion(result)
    }

    private func attemptComplete(result: Result<Value, HttpConnectorFailure>) {
        guard case let .executing(executingState) = state else {
            return
        }
        if case .failure(let failure) = result,
           shouldRetryRequest(after: failure),
           executingState.retryCount < retryStrategy.maximumRetries {
            let retryDelay = retryStrategy.interval(for: executingState.retryCount)
            let timer = Timer.scheduledTimer(withTimeInterval: retryDelay, repeats: false) { [self] _ in
                guard case .waiting = state else {
                    return
                }
                let cancellable = GroupCancellable()
                let executingState = HttpConnectorRetryDecoratorOperationState.Executing(
                    cancellable: cancellable, retryCount: executingState.retryCount + 1
                )
                state = .executing(executingState)
                cancellable.add(connector.execute(request: request, completion: attemptComplete))
            }
            state = .waiting(timer)
        } else {
            setCompletedState(result: result)
        }
    }

    private func shouldRetryRequest(after failure: HttpConnectorFailure) -> Bool {
        switch failure {
        case .networkUnreachable, .timeout:
            return true
        case .server(_, let statusCode):
            return (500...599).contains(statusCode)
        default:
            return false
        }
    }
}
