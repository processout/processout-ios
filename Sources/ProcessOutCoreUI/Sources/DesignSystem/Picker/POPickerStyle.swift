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
    @ViewBuilder func makeBody(configuration: POPickerStyleConfiguration) -> Self.Body
}

@_spi(PO)
public struct POPickerStyleConfiguration {

    /// Picker elements.
    public let elements: [POPickerStyleConfigurationElement]

    /// Boolean value indicating whether selection (or lack of it) makes picker invalid.
    public let isInvalid: Bool
}

@_spi(PO)
public struct POPickerStyleConfigurationElement: Identifiable {

    /// The stable identity of the element.
    public let id: AnyHashable

    /// Returns the appearance for the picker element.
    public let makeBody: () -> Text

    /// Boolean value indicating whether element is currently selected.
    public let isSelected: Bool

    /// Invoke to select element.
    public let select: () -> Void
}
