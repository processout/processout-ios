//
//  POCodeField.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 13.06.2024.
//

import SwiftUI

@_spi(PO)
@MainActor
public struct POCodeField<Label: View>: View {

    public init(text: Binding<String>, length: Int, @ViewBuilder label: () -> Label = { EmptyView() }) {
        self.length = length
        self.label = label()
        _text = text
        isMenuVisible = false
    }

    // MARK: - View

    public var body: some View {
        let insertionPoint = Binding<String.Index?> {
            textIndex
        } set: { newInsertionPoint in
            focusableView.setFocused(newInsertionPoint != nil)
            textIndex = newInsertionPoint
        }
        let configuration = CodeFieldStyleConfiguration(
            text: text,
            length: length,
            label: AnyView(label),
            insertionPoint: insertionPoint,
            isEditing: focusableView.isFocused
        )
        AnyView(style.makeBody(configuration: configuration))
            .background(
                CodeFieldRepresentable(
                    length: length,
                    text: $text,
                    textIndex: $textIndex,
                    isMenuVisible: $isMenuVisible,
                    focusableView: $focusableView
                )
            )
            .onLongPressGesture {
                isMenuVisible = true
            }
            .backport.onChange(of: text) {
                isMenuVisible = false
            }
            .onReceive(notification: UIMenuController.didHideMenuNotification) { _ in
                isMenuVisible = false
            }
            .backport.onChange(of: focusableView.isFocused) {
                if !focusableView.isFocused {
                    textIndex = nil
                    isMenuVisible = false
                } else if textIndex == nil {
                    textIndex = text.endIndex
                }
            }
            .preference(key: FocusableViewProxyPreferenceKey.self, value: focusableView)
            .backport.geometryGroup()
    }

    // MARK: - Private Properties

    @Binding
    private var text: String

    private let length: Int

    /// Code field label.
    private let label: Label

    @State
    private var textIndex: String.Index?

    @State
    private var isMenuVisible: Bool

    @Environment(\.codeFieldStyle)
    private var style

    @State
    private var focusableView = FocusableViewProxy()
}
