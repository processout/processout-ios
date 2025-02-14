//
//  POUnfairlyLocked.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.07.2023.
//

import os

/// A thread-safe wrapper around a value.
@_spi(PO)
public final class POUnfairlyLocked<Value>: @unchecked Sendable {

    public init(wrappedValue: Value) {
        unfairLock = .allocate(capacity: 1)
        unfairLock.initialize(to: os_unfair_lock())
        value = wrappedValue
    }

    deinit {
        unfairLock.deinitialize(count: 1)
        unfairLock.deallocate()
    }

    /// The contained value. Unsafe for anything more than direct read or write.
    public var wrappedValue: Value {
        withLock { $0 }
    }

    public var projectedValue: POUnfairlyLocked<Value> {
        self
    }

    public func withLock<R, E: Error>(_ body: (inout Value) throws(E) -> R) throws(E) -> R {
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

    public func withLock<R, E: Error>(_ body: () throws(E) -> R) throws(E) -> R {
        try withLock { _ throws(E) in
            try body()
        }
    }
}

extension POUnfairlyLocked {

    /// Convenience to create lock when value type is `Void`.
    public convenience init() where Value == Void {
        self.init(wrappedValue: ())
    }

    /// Convenience to create lock when value type is `Void`.
    public convenience init<T>() where T? == Value {
        self.init(wrappedValue: nil)
    }
}
