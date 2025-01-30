//
//  POTextField.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 06.09.2023.
//

import SwiftUI

@_spi(PO)
@available(iOS 14, *)
@MainActor
public struct POTextField<Trailing: View>: View {

    public init(
        text: Binding<String>,
        formatter: Formatter? = nil,
        prompt: String = "",
        trailingView: Trailing = EmptyView()
    ) {
        self._text = text
        self.formatter = formatter
        self.prompt = prompt
        self.trailingView = trailingView
    }

    public var body: some View {
        let configuration = POTextFieldStyleConfiguration(
            text: $text,
            isEditing: focusableView.isFocused ?? false,
            textField: {
                TextFieldRepresentable(text: $text, formatter: formatter, focusableView: $focusableView)
            },
            prompt: Text(prompt),
            trailingView: {
                trailingView
            }
        )
        AnyView(style.makeBody(configuration: configuration))
            .preference(key: FocusableViewProxyPreferenceKey.self, value: focusableView)
    }

    // MARK: - Private Properties

    private let formatter: Formatter?, prompt: String, trailingView: Trailing

    @Binding
    private var text: String

    @Environment(\.poTextFieldStyle)
    private var style

    @State
    private var focusableView = FocusableViewProxy()
}
