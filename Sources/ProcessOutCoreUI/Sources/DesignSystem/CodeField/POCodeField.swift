//
//  POCodeField.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 13.06.2024.
//

import SwiftUI

@_spi(PO)
@available(iOS 14, *)
@MainActor
public struct POCodeField: View {

    public init(text: Binding<String>, length: Int) {
        self.length = length
        _text = text
        isMenuVisible = false
    }

    // MARK: - View

    public var body: some View {
        let configuration = CodeFieldStyleConfiguration(length: length, text: text, index: textIndex) { newIndex in
            focusCoordinator.beginEditing()
            textIndex = newIndex
        }
        AnyView(style.makeBody(configuration: configuration))
            .background(
                CodeFieldRepresentable(
                    length: length, text: $text, textIndex: $textIndex, isMenuVisible: $isMenuVisible
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
            .backport.onChange(of: focusCoordinator.isEditing) {
                if !focusCoordinator.isEditing {
                    textIndex = nil
                    isMenuVisible = false
                } else if textIndex == nil {
                    textIndex = text.endIndex
                }
            }
            .backport.geometryGroup()
    }

    // MARK: - Private Properties

    private let length: Int

    @Binding
    private var text: String

    @State
    private var textIndex: String.Index?

    @State
    private var isMenuVisible: Bool

    @Environment(\.codeFieldStyle)
    private var style

    @EnvironmentObject
    private var focusCoordinator: FocusCoordinator
}
