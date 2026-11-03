//
//  Result+Async.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.11.2026.
//

#if compiler(<6.4)

extension Result {

    /// Creates a new result by evaluating the given async throwing closure, capturing the
    /// returned value as a success, or the thrown error as a failure.
    ///
    /// - NOTE: Standard library provides this initializer starting with Swift 6.4.
    init(catching body: () async throws(Failure) -> Success) async {
        do throws(Failure) {
            self = .success(try await body())
        } catch {
            self = .failure(error)
        }
    }
}

#endif
