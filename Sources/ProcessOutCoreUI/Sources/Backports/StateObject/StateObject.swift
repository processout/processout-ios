//
//  StateObject.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 05.10.2023.
//

import Combine
import SwiftUI

@available(iOS, deprecated: 14.0)
extension POBackport where Wrapped: ObservableObject {

    /// A property wrapper type that instantiates an observable object.
    @propertyWrapper
    public struct StateObject: DynamicProperty {

        /// The underlying value referenced by the state object.
        public var wrappedValue: Wrapped {
            if let object = state.value {
                return object
            } else {
                let object = thunk()
                state.value = object
                return object
            }
        }

        /// A projection of the state object that creates bindings to its properties.
        public var projectedValue: ObservedObject<Wrapped>.Wrapper {
            ObservedObject(wrappedValue: wrappedValue).projectedValue
        }

        /// Creates a new state object with an initial wrapped value.
        public init(wrappedValue thunk: @autoclosure @escaping () -> Wrapped) {
            self.thunk = thunk
        }

        public mutating func update() {
            if state.value == nil {
                state.value = thunk()
            }
            if observedObject.value !== state.value {
                observedObject.value = state.value
            }
        }

        // MARK: - Private Properties

        private let thunk: () -> Wrapped

        @State
        private var state = Wrapper()

        @ObservedObject
        private var observedObject = Wrapper()
    }

    private final class Wrapper: ObservableObject {

        var value: Wrapped? {
            didSet {
                cancellable = nil
                cancellable = value?.objectWillChange.sink { [subject] _ in subject.send() }
            }
        }

        var objectWillChange: AnyPublisher<Void, Never> {
            subject.eraseToAnyPublisher()
        }

        // MARK: - Private Methods

        private var subject = PassthroughSubject<Void, Never>()
        private var cancellable: AnyCancellable?
    }
}
