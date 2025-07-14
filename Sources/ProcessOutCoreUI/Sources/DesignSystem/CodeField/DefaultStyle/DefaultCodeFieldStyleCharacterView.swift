//
//  BorderedTextFieldStyleCharacterView.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 14.06.2024.
//

import SwiftUI

@MainActor
struct DefaultCodeFieldStyleCharacterView: View {

    enum CaretAlignment: Equatable {
        case leading, trailing
    }

    /// Single value.
    let value: Character

    /// Caret alignment.
    @Binding
    var caretAlignment: CaretAlignment?

    // MARK: - View

    var body: some View {
        let style = style.resolve(isInvalid: isInvalid, isFocused: caretAlignment != nil)
        Text(value.description)
            .textStyle(style.text)
            .lineLimit(1)
            .minimumScaleFactor(0.001)
            .padding(.horizontal, POSpacing.space4)
            .overlay(makeCaretOverlay())
            .padding(POSpacing.extraSmall)
            .frame(maxWidth: 40, idealHeight: 52)
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

    // MARK: -

    @ViewBuilder
    private func makeCaretOverlay() -> some View {
        if let caretAlignment {
            Rectangle()
                .fill(Color.accentColor)
                .frame(width: 2)
                .blink(animation: .easeInOut(duration: 0.4))
                .frame(maxWidth: .infinity, alignment: caretAlignment == .leading ? .leading : .trailing)
        }
    }

    private var makeSelectionOverlay: some View {
        // Tap gesture that exposes location is unavailable on earlier iOS versions
        // so two separate views are used to understand what view part was tapped.
        HStack(spacing: 0) {
            Color.clear.contentShape(.rect).onTapGesture {
                caretAlignment = .leading
            }
            Color.clear.contentShape(.rect).onTapGesture {
                caretAlignment = .trailing
            }
        }
    }
}
