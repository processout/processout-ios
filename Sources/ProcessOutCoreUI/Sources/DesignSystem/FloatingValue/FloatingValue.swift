//
//  FloatingValue.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 11.06.2025.
//

import SwiftUI

/// A container view that overlays a placeholder on top of a value view, supporting
/// a floating-label effect similar to Material Design's floating placeholders.
struct FloatingValue<Value: View, ValueSizingView: View, Placeholder: View>: View {

    init(
        isFloating: Bool,
        spacing: CGFloat? = nil,
        animation: Animation? = .default,
        @ViewBuilder value: () -> Value,
        @ViewBuilder valueSizingView: () -> ValueSizingView = { EmptyView() },
        @ViewBuilder placeholder: @escaping (_ isFloating: Bool) -> Placeholder
    ) {
        self.isFloating = isFloating
        self.spacing = spacing
        self.animation = animation
        self.value = value()
        self.valueSizingView = valueSizingView()
        self.placeholder = placeholder
    }

    // MARK: - View

    var body: some View {
        let alignment = Alignment(horizontal: .leading, vertical: .center)
        ZStack(alignment: alignment) {
            VStack(alignment: alignment.horizontal, spacing: spacing) {
                resolvedPlaceholder
                ViewThatExists {
                    valueSizingView
                    value
                }
            }
            .hidden()
            VStack(alignment: alignment.horizontal, spacing: spacing) {
                resolvedPlaceholder
                if isFloating {
                    ViewThatExists {
                        valueSizingView
                        value
                    }
                    .hidden()
                }
            }
            .animation(animation, value: isFloating)
            VStack(alignment: alignment.horizontal, spacing: spacing) {
                if isFloating {
                    resolvedPlaceholder.hidden()
                }
                value
            }
        }
        .backport.geometryGroup()
    }

    // MARK: - Private Properties

    /// A Boolean value that determines whether the placeholder should float.
    private let isFloating: Bool

    /// Optional vertical spacing between the placeholder and the value view.
    private let spacing: CGFloat?

    /// The animation applied to the placeholder's scale and position changes
    /// when transitioning between the normal and floated states.
    private let animation: Animation?

    /// The main content view.
    private let value: Value

    /// A hidden sizing view used to match the layout and reserve the correct space for the `value` view.
    private let valueSizingView: ValueSizingView

    /// The placeholder view shown in the background.
    private let placeholder: (Bool) -> Placeholder

    // MARK: - Private Methods

    private var resolvedPlaceholder: some View {
        placeholder(isFloating)
    }
}
