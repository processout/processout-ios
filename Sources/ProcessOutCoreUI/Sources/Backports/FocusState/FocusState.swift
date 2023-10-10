//
//  POFocusState.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 03.10.2023.
//

import SwiftUI

extension POBackport where Wrapped == Any {

    @propertyWrapper
    public struct FocusState<Value>: DynamicProperty where Value: Hashable {

        public var projectedValue: Binding<Value> {
            Binding(
                get: { wrappedValue },
                set: { wrappedValue = $0 }
            )
        }

        public var wrappedValue: Value {
            get { value }
            nonmutating set { value = newValue }
        }

        public init() where Value == Bool {
            _value = .init(initialValue: false)
        }

        public init<T: Hashable>() where Value == T?, T: Hashable {
            _value = .init(initialValue: nil)
        }

        // MARK: - Private Properties

        @State private var value: Value
    }
}
