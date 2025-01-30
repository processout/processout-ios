//
//  POTextFieldStyleConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 30.01.2025.
//

import SwiftUI

@_spi(PO)
@MainActor
public struct POTextFieldStyleConfiguration {

    /// The text value being displayed and selected.
    @Binding
    public var text: String

    /// Boolean value indicating whether view is currently being edited.
    public let isEditing: Bool

    /// Actual text field content.
    public let textField: AnyView

    /// A Text representing the prompt of the text field which provides users with
    /// guidance on what to type into the text field.
    public let prompt: Text

    /// Trailing view if any.
    public let trailingView: AnyView

    init(
        text: Binding<String>,
        isEditing: Bool,
        @ViewBuilder textField: () -> some View,
        prompt: Text,
        @ViewBuilder trailingView: () -> some View
    ) {
        self._text = text
        self.isEditing = isEditing
        self.textField = AnyView(textField())
        self.prompt = prompt
        self.trailingView = AnyView(trailingView())
    }
}
