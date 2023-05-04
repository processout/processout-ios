//
//  AnyEquatable.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.05.2023.
//

struct AnyEquatable: Equatable {

    init<E: Equatable>(_ base: E) {
        self.base = base
        self.equals = { $0 as? E == base }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.equals(rhs.base)
    }

    /// The value wrapped by this instance.
    let base: Any

    // MARK: - Private Properties

    private let equals: (Any) -> Bool
}
