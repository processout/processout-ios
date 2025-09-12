//
//  POUnfairlyLocked.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.07.2023.
//

import os

/// A thread-safe wrapper around a value.
package final class POUnfairlyLocked<Value>: @unchecked Sendable {

    package init(wrappedValue: Value) {
        unfairLock = .allocate(capacity: 1)
        unfairLock.initialize(to: os_unfair_lock())
        value = wrappedValue
    }

    deinit {
        unfairLock.deinitialize(count: 1)
        unfairLock.deallocate()
    }

    /// The contained value. Unsafe for anything more than direct read or write.
    package var wrappedValue: Value {
        withLock { $0 }
    }

    package var projectedValue: POUnfairlyLocked<Value> {
        self
    }

    package func withLock<R>(_ body: (inout Value) throws -> R) rethrows -> R {
        defer {
            os_unfair_lock_unlock(unfairLock)
        }
        os_unfair_lock_lock(unfairLock)
        return try body(&value)
    }

    // MARK: - Private Properties

    private let unfairLock: os_unfair_lock_t
    private var value: Value
}

extension POUnfairlyLocked where Value == Void {

    package func withLock<R>(_ body: () throws -> R) rethrows -> R {
        try withLock { _ in try body() }
    }
}

extension POUnfairlyLocked {

    /// Convenience to create lock when value type is `Void`.
    package convenience init() where Value == Void {
        self.init(wrappedValue: ())
    }

    /// Convenience to create lock when value type is `Void`.
    package convenience init<T>() where T? == Value {
        self.init(wrappedValue: nil)
    }
}
