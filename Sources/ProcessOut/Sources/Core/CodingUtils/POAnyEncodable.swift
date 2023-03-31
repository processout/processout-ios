//
//  POAnyEncodable.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2022.
//

import Foundation

/// A type-erased `Encodable` value.
///
/// The `POAnyEncodable` type forwards encode operation to an underlying encodable value, hiding the type of the
/// wrapped value.
///
/// You can store mixed-type values in dictionaries and other collections that require Encodable conformance by
/// wrapping mixed-type values in AnyEncodable instances:
///
/// ```swift
/// let array = [AnyEncodable(123), AnyEncodable("456")]
/// try JSONEncoder().encode(array)
/// ```
public struct POAnyEncodable: Encodable {

    private let encoding: (Encoder) throws -> Void

    public init<Value: Encodable>(_ value: Value) {
        encoding = value.encode(to:)
    }

    public func encode(to encoder: Encoder) throws {
        try encoding(encoder)
    }
}
