//
//  ImmutableNullHashable.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.04.2023.
//

@propertyWrapper
struct ImmutableNullHashable<Value>: Hashable {

    let wrappedValue: Value

    static func == (lhs: Self, rhs: Self) -> Bool {
        true
    }

    func hash(into hasher: inout Hasher) {
        // Ignored
    }
}

extension ImmutableNullHashable: Sendable where Value: Sendable { }
