//
//  POUnfairlyLocked.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.07.2023.
//

import os

/// A thread-safe wrapper around a value.
@propertyWrapper
@_spi(PO) public final class POUnfairlyLocked<Value>: @unchecked Sendable {

    public init(wrappedValue: Value) {
        value = wrappedValue
    }

    /// The contained value. Unsafe for anything more than direct read or write.
    public var wrappedValue: Value {
        lock.withLock { value }
    }

    public var projectedValue: POUnfairlyLocked<Value> {
        self
    }

    public func withLock<R>(_ body: (inout Value) -> R) -> R {
        lock.withLock {
            body(&value)
        }
    }

    // MARK: - Private Properties

    private let lock = UnfairLock()
    private var value: Value
}
