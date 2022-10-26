//
//  ImmutableExcludedCodable.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.10.2022.
//

import Foundation

@propertyWrapper
public struct ImmutableExcludedCodable<Value>: Encodable {

    public let wrappedValue: Value

    /// Creates property wrapper instance.
    public init(value: Value) {
        self.wrappedValue = value
    }

    public func encode(to encoder: Encoder) throws { }
}
