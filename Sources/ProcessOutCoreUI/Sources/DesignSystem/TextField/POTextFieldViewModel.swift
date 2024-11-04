//
//  POTextFieldViewModel.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.11.2024.
//

import SwiftUI

@_spi(PO)
public struct POTextFieldViewModel: Identifiable {

    /// Item identifier.
    public let id: AnyHashable

    /// Current parameter's value text.
    @Binding
    public var value: String

    /// Parameter's placeholder.
    public let placeholder: String

    /// Input icon.
    public let icon: AnyView?

    /// Boolean value indicating whether value is valid.
    public let isInvalid: Bool

    /// Boolean value indicating whether input is currently enabled.
    public let isEnabled: Bool

    /// Formatter to use to format value if any.
    public let formatter: Formatter?

    /// Keyboard type.
    public let keyboard: UIKeyboardType

    /// Text content type.
    public let contentType: UITextContentType?

    /// Submit label.
    public let submitLabel: POBackport<Any>.SubmitLabel

    /// Action to perform when the user submits a value to this input.
    public let onSubmit: () -> Void

    public init(
        id: AnyHashable,
        value: Binding<String>,
        placeholder: String,
        icon: AnyView?,
        isInvalid: Bool,
        isEnabled: Bool,
        formatter: Formatter?,
        keyboard: UIKeyboardType,
        contentType: UITextContentType?,
        submitLabel: POBackport<Any>.SubmitLabel,
        onSubmit: @escaping () -> Void
    ) {
        self.id = id
        self._value = value
        self.placeholder = placeholder
        self.icon = icon
        self.isInvalid = isInvalid
        self.isEnabled = isEnabled
        self.formatter = formatter
        self.keyboard = keyboard
        self.contentType = contentType
        self.submitLabel = submitLabel
        self.onSubmit = onSubmit
    }
}
