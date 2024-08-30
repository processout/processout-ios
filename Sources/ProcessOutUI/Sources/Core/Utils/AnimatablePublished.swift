//
//  AnimatablePublished.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 06.06.2024.
//

import SwiftUI
import Combine

// swiftlint:disable fatal_error_message unused_setter_value

/// A type that publishes a property marked with an attribute and animates changes.
@propertyWrapper
struct AnimatablePublished<T> where T: AnimationIdentityProvider {

    init(wrappedValue: T, animation: Animation = .default) {
        self.value = wrappedValue
        self.animation = animation
        storage = Storage()
    }

    @available(*, unavailable, message: "@AnimatablePublished is only available on properties of classes")
    var wrappedValue: T {
        get { fatalError() }
        set { fatalError() }
    }

    var projectedValue: Self {
        self
    }

    /// Disables animations for mutations performed within given closure.
    func performWithoutAnimation(_ actionsWithoutAnimation: () -> Void) {
        storage.areAnimationsEnabled = false
        actionsWithoutAnimation()
        storage.areAnimationsEnabled = true
    }

    static subscript<Instance: ObservableObject>(
        _enclosingInstance observed: Instance,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<Instance, T>,
        storage storageKeyPath: ReferenceWritableKeyPath<Instance, Self>
    ) -> T where Instance.ObjectWillChangePublisher == ObservableObjectPublisher {
        get {
            observed[keyPath: storageKeyPath].value
        }
        set {
            // Changes that may affect layout are animated explicitly to ensure whole view hierarchy
            // is animated properly. Using `withAnimation` inside view model is not perfect (ideally
            // it should be done by view only) but is simpler.
            let areAnimationsEnabled = observed[keyPath: storageKeyPath].storage.areAnimationsEnabled
            let oldAnimationIdentity = observed[keyPath: storageKeyPath].value.animationIdentity
            let isAnimated = oldAnimationIdentity != newValue.animationIdentity && areAnimationsEnabled
            withAnimation(isAnimated ? observed[keyPath: storageKeyPath].animation : nil) {
                observed.objectWillChange.send()
                observed[keyPath: storageKeyPath].value = newValue
            }
        }
    }

    // MARK: - Private Nested Types

    private final class Storage {

        /// Boolean value indicating whether animations are enabled.
        var areAnimationsEnabled = true
    }

    // MARK: - Private Properties

    private let animation: Animation
    private let storage: Storage

    /// Current value.
    private var value: T
}

protocol AnimationIdentityProvider {

    /// Animation identity. For now only properties that may affect layout
    /// changes are part of identity.
    ///
    /// Use ``AnimatableProperty`` wrapper for view model's state
    /// to automatically decide whether animation should be applied.
    ///
    /// - NOTE: When this property changes view should be updated with
    /// explicit animation.
    var animationIdentity: AnyHashable { get }
}

// swiftlint:enable fatal_error_message unused_setter_value
