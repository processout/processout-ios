//
//  ReferenceTypeBox.swift
//  Example
//
//  Created by Andrii Vysotskyi on 15.03.2023.
//

import Foundation

@propertyWrapper
final class ReferenceTypeBox<Value> {

    typealias Observer = (_ value: Value) -> Void

    init(value: Value) {
        self.wrappedValue = value
        observers = [:]
    }

    var wrappedValue: Value {
        didSet { wrappedValueDidChange() }
    }

    var projectedValue: ReferenceTypeBox<Value> {
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

extension ReferenceTypeBox: Hashable, Equatable where Value: Hashable {

    static func == (lhs: ReferenceTypeBox, rhs: ReferenceTypeBox) -> Bool {
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
