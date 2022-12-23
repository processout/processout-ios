//
//  POAnyEncodable.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2022.
//

import Foundation

public struct POAnyEncodable: Encodable {

    private let encoding: (Encoder) throws -> Void

    public init<Value: Encodable>(_ value: Value) {
        encoding = value.encode(to:)
    }

    public func encode(to encoder: Encoder) throws {
        try encoding(encoder)
    }
}
