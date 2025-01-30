//
//  PODefaultTextFieldStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 30.01.2025.
//

import SwiftUI

/// The default text field style that resolves its appearance based on current input style.
@_spi(PO)
@available(iOS 14, *)
public struct PODefaultTextFieldStyle: POTextFieldStyle {

    public func makeBody(configuration: Configuration) -> some View {
        DefaultTextFieldStyleContentView(configuration: configuration)
    }
}

@available(iOS 14, *)
private struct DefaultTextFieldStyleContentView: View {

    let configuration: POTextFieldStyleConfiguration

    // MARK: - View

    var body: some View {
        let resolvedStyle = inputStyle.resolve(isInvalid: isInvalid, isFocused: configuration.isEditing)
        HStack {
            ZStack(alignment: .leading) {
                configuration.textField
                    .textStyle(resolvedStyle.text)
                configuration.prompt
                    .lineLimit(1)
                    .textStyle(resolvedStyle.placeholder)
                    .allowsHitTesting(false)
                    .opacity(configuration.text.isEmpty ? 1 : 0)
                    .transaction { transaction in
                        transaction.animation = nil
                    }
            }
            configuration.trailingView
                .foregroundColor(
                    configuration.text.isEmpty ? resolvedStyle.placeholder.color : resolvedStyle.text.color
                )
        }
        .padding(Constants.padding)
        .frame(maxWidth: .infinity, minHeight: Constants.minHeight)
        .background(resolvedStyle.backgroundColor)
        .border(style: resolvedStyle.border)
        .shadow(style: resolvedStyle.shadow)
        .accentColor(resolvedStyle.tintColor)
        .animation(.default, value: isInvalid)
        .backport.geometryGroup()
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let minHeight: CGFloat = 48
        static let padding = EdgeInsets(horizontal: POSpacing.medium, vertical: POSpacing.extraSmall)
    }

    // MARK: - Private Properties

    @Environment(\.inputStyle)
    private var inputStyle

    @Environment(\.isControlInvalid)
    private var isInvalid
}
