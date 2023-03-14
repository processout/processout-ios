//
//  CardPaymentViewModelType.swift
//  Example
//
//  Created by Andrii Vysotskyi on 10.03.2023.
//

import Foundation

protocol CardPaymentViewModelType: ViewModelType<CardPaymentViewModelState> {

    /// Initiates card payment.
    func pay()
}

enum CardPaymentViewModelState {

    struct SectionIdentifier: Hashable {

        /// Section title.
        let title: String
    }

    struct Section {

        /// Section identifier.
        let identifier: SectionIdentifier

        /// Section items.
        let parameters: [Parameter]
    }

    struct Parameter: Hashable {

        /// Parameter value.
        @ValueMutableReferenceBox
        var value: String

        /// Parameter placeholder.
        let placeholder: String

        /// Accessibility identifier.
        let accessibilityId: String
    }

    struct Started {

        /// Available items.
        let sections: [Section]
    }

    case idle, started(Started)
}

@propertyWrapper
final class ValueMutableReferenceBox<Value> {

    typealias Observer = (_ value: Value) -> Void

    init(value: Value) {
        self.wrappedValue = value
        observers = [:]
    }

    var wrappedValue: Value {
        didSet { wrappedValueDidChange() }
    }

    var projectedValue: ValueMutableReferenceBox<Value> {
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

extension ValueMutableReferenceBox: Hashable, Equatable where Value: Hashable {

    static func == (lhs: ValueMutableReferenceBox, rhs: ValueMutableReferenceBox) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
    }
}
