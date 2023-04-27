//
//  ReferenceTypeWrapper.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.04.2023.
//

import Foundation

@propertyWrapper
final class ReferenceTypeWrapper<Value> {

    typealias Observer = (_ value: Value) -> Void

    init(value: Value) {
        self.wrappedValue = value
        observers = [:]
    }

    var wrappedValue: Value {
        didSet { wrappedValueDidChange() }
    }

    var projectedValue: ReferenceTypeWrapper<Value> {
        self
    }

    func addObserver(_ observer: @escaping Observer) -> AnyObject {
        let id = UUID().uuidString
        observers[id] = observer
        let cancellable = Cancellable { [weak self] in
            self?.observers[id] = nil
        }
        return cancellable
    }

    // MARK: - Private Nested Types

    private final class Cancellable {

        let didCancel: () -> Void

        init(didCancel: @escaping () -> Void) {
            self.didCancel = didCancel
        }

        deinit {
            didCancel()
        }
    }

    // MARK: - Private

    private var observers: [String: Observer]

    private func wrappedValueDidChange() {
        observers.values.forEach { $0(wrappedValue) }
    }
}

extension ReferenceTypeWrapper: Hashable, Equatable where Value: Hashable {

    static func == (lhs: ReferenceTypeWrapper, rhs: ReferenceTypeWrapper) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue && lhs.observerIds == rhs.observerIds
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
        hasher.combine(observerIds)
    }

    // MARK: - Private Properties

    private var observerIds: Set<String> {
        Set(observers.keys)
    }
}
