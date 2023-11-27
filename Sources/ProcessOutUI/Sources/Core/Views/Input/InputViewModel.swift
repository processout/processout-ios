//
//  InputViewModel.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 13.11.2023.
//

import SwiftUI

struct InputViewModel: Identifiable {

    /// Item identifier.
    let id: AnyHashable

    /// Current parameter's value text.
    @Binding var value: String

    /// Parameter's placeholder.
    let placeholder: String

    /// Boolean value indicating whether value is valid.
    let isInvalid: Bool

    /// Boolean value indicating whether input is currently enabled.
    let isEnabled: Bool

    /// Input icon.
    let icon: Image?

    /// Formatter to use to format value if any.
    let formatter: Formatter?

    /// Keyboard type.
    let keyboard: UIKeyboardType

    /// Text content type.
    let contentType: UITextContentType?

    /// Action to perform when the user submits a value to this input.
    let onSubmit: () -> Void
}
