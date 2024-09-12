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

    public func withLock<R>(_ body: (inout Value) throws -> R) rethrows -> R {
        try lock.withLock { try body(&value) }
    }

    // MARK: - Private Properties

    private let lock = UnfairLock()
    private var value: Value
}

extension POUnfairlyLocked where Value == Void {

    /// Convenience to create lock when value type is `Void`.
    public convenience init() where Value == Void {
        self.init(wrappedValue: ())
    }

    public func withLock<R>(_ body: () throws -> R) rethrows -> R {
        try withLock { _ in try body() }
    }
}
