//
//  Binding+Hashable.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 21.03.2024.
//

import SwiftUI

extension Binding: Hashable, Equatable where Value: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.wrappedValue)
    }

    public static func == (lhs: Binding, rhs: Binding) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}
