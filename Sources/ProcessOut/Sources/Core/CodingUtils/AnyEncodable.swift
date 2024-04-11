//
//  AnyEncodable.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.11.2023.
//

import Foundation

struct AnyEncodable: Encodable {

    init<T: Encodable>(_ value: T) {
        _encode = value.encode(to:)
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }

    // MARK: - Private Properties

    private let _encode: (Encoder) throws -> Void
}
