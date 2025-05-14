//
//  POPickerStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 13.10.2023.
//

import SwiftUI

/// A type that specifies the appearance and interaction of all pickers
/// within a view hierarchy.
@_spi(PO)
@MainActor
@preconcurrency
public protocol POPickerStyle: Sendable {

    /// A view representing the appearance and interaction of a `POPicker`.
    associatedtype Body: View

    /// Returns the appearance and interaction content for a `POPicker`.
    ///
    /// - Parameter configuration : The properties of the date picker.
    @ViewBuilder func makeBody(configuration: Configuration) -> Self.Body

    /// The properties of a picker.
    typealias Configuration = POPickerStyleConfiguration
}

@_spi(PO)
public struct POPickerStyleConfiguration {

    /// The date value being displayed and selected.
    @Binding
    public var selection: AnyHashable?

    /// Content.
    public let content: AnyView

    /// Prompt.
    public let prompt: AnyView

    /// Label describing current value.
    public let currentValueLabel: AnyView

    init(
        selection: Binding<AnyHashable?>,
        @ViewBuilder content: () -> some View,
        @ViewBuilder prompt: () -> some View,
        @ViewBuilder currentValueLabel: () -> some View
    ) {
        self._selection = selection
        self.content = AnyView(content())
        self.prompt = AnyView(prompt())
        self.currentValueLabel = AnyView(currentValueLabel())
    }
}
