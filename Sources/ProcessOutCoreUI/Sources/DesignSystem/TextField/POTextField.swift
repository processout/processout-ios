//
//  POTextField.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 06.09.2023.
//

import SwiftUI

@_spi(PO)
@MainActor
public struct POTextField<Trailing: View>: View {

    public init(
        text: Binding<String>,
        formatter: Formatter? = nil,
        prompt: String = "",
        trailingView: Trailing = EmptyView(),
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
    ) {
        self._text = text
        self.formatter = formatter
        self.prompt = prompt
        self.trailingView = trailingView
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
    }

    public var body: some View {
        let configuration = POTextFieldStyleConfiguration(
            text: $text,
            isEditing: focusableView.isFocused,
            textField: {
                TextFieldRepresentable(
                    text: $text,
                    formatter: formatter,
                    focusableView: $focusableView,
                    accessibilityLabel: accessibilityLabel ?? prompt,
                    accessibilityHint: accessibilityHint,
                )
            },
            prompt: Text(prompt),
            trailingView: {
                trailingView
            }
        )
        AnyView(style.makeBody(configuration: configuration))
            .preference(key: FocusableViewProxyPreferenceKey.self, value: focusableView)
            .backport.onChange(of: formatter) {
                if let formattedText = formatter?.string(for: text), formattedText != text {
                    text = formattedText
                }
            }
    }

    // MARK: - Private Properties

    private let formatter: Formatter?, prompt: String, trailingView: Trailing

    /// Accessibility.
    private let accessibilityLabel: String?, accessibilityHint: String?

    @Binding
    private var text: String

    @Environment(\.poTextFieldStyle)
    private var style

    @State
    private var focusableView = FocusableViewProxy()
}
