//
//  AutoCompletion+Invoke.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.12.2023.
//

/// Invokes given completion with a result of async operation.
func invoke<T>(
    completion: @escaping (Result<T, POFailure>) -> Void,
    after operation: @escaping () async throws -> T
) -> POCancellable {
    Task { @MainActor in
        do {
            let returnValue = try await operation()
            completion(.success(returnValue))
        } catch let failure as POFailure {
            completion(.failure(failure))
        } catch {
            let failure = POFailure(code: .internal(.mobile), underlyingError: error)
            completion(.failure(failure))
        }
    }
}

/// Invokes given completion with a result of async operation.
func invoke<T>(completion: @escaping (T) -> Void, after operation: @escaping () async -> T) -> Task<Void, Never> {
    Task { @MainActor in
        completion(await operation())
    }
}
