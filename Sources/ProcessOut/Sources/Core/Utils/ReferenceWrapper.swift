//
//  ReferenceWrapper.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.04.2023.
//

import Foundation

@propertyWrapper
final class ReferenceWrapper<Value> {

    typealias Observer = (_ value: Value) -> Void

    init(value: Value) {
        self.wrappedValue = value
        observers = [:]
    }

    var wrappedValue: Value {
        didSet { wrappedValueDidChange() }
    }

    var projectedValue: ReferenceWrapper<Value> {
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

extension ReferenceWrapper: Hashable, Equatable where Value: Hashable {

    static func == (lhs: ReferenceWrapper, rhs: ReferenceWrapper) -> Bool {
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
