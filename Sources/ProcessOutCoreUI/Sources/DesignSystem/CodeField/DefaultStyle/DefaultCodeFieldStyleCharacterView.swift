//
//  BorderedTextFieldStyleCharacterView.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 14.06.2024.
//

import SwiftUI

@available(iOS 14.0, *)
@MainActor
struct DefaultCodeFieldStyleCharacterView: View {

    enum CaretPosition: Equatable {
        case before, after
    }

    /// Single value.
    let value: Character

    /// Caret position.
    let caretPosition: CaretPosition?

    /// Closure is called when user requests caret position change.
    let select: (CaretPosition) -> Void

    // MARK: - View

    var body: some View {
        let style = style.resolve(isInvalid: isInvalid, isFocused: focusCoordinator.isEditing && caretPosition != nil)
        Text(value.description)
            .textStyle(style.text)
            .lineLimit(1)
            .minimumScaleFactor(0.001)
            .padding(.horizontal, POSpacing.extraSmall)
            .overlay(caretPosition.map(makeCaretOverlay))
            .padding(POSpacing.extraSmall)
            .frame(maxWidth: 44, idealHeight: 48)
            .fixedSize(horizontal: false, vertical: true)
            .background(style.backgroundColor)
            .border(style: style.border)
            .shadow(style: style.shadow)
            .overlay(makeSelectionOverlay)
            .accentColor(style.tintColor)
            .animation(.default, value: isInvalid)
    }

    // MARK: - Private Properties

    @Environment(\.inputStyle)
    private var style

    @Environment(\.isControlInvalid)
    private var isInvalid

    @EnvironmentObject
    private var focusCoordinator: FocusCoordinator

    // MARK: -

    @ViewBuilder
    private func makeCaretOverlay(position: CaretPosition) -> some View {
        Rectangle()
            .fill(Color.accentColor)
            .frame(width: 2)
            .blink(animation: .easeInOut(duration: 0.4))
            .frame(maxWidth: .infinity, alignment: caretPosition == .before ? .leading : .trailing)
    }

    private var makeSelectionOverlay: some View {
        // Tap gesture that exposes location is unavailable on earlier iOS versions
        // so two separate views are used to understand what view part was tapped.
        HStack(spacing: 0) {
            Color.clear.contentShape(.rect).onTapGesture {
                select(.before)
            }
            Color.clear.contentShape(.rect).onTapGesture {
                select(.after)
            }
        }
    }
}
