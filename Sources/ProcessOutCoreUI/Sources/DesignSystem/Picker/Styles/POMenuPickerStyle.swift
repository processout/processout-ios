//
//  POMenuPickerStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 13.10.2023.
//

import SwiftUI

@_spi(PO)
@available(iOS 14, *)
public struct POMenuPickerStyle: POPickerStyle {

    public init(inputStyle: POInputStyle) {
        self.inputStyle = inputStyle
    }

    public func makeBody(configuration: POPickerStyleConfiguration) -> some View {
        ContentView(inputStyle: inputStyle, configuration: configuration)
    }

    // MARK: - Private Properties

    private let inputStyle: POInputStyle
}

@available(iOS 14, *)
extension POPickerStyle where Self == POMenuPickerStyle {

    /// A picker style that presents the options as a menu when the user
    /// presses a button, or as a submenu when nested within a larger menu.
    public static var menu: POMenuPickerStyle {
        POMenuPickerStyle(inputStyle: .medium)
    }
}

@MainActor
@available(iOS 14, *)
private struct ContentView: View {

    let inputStyle: POInputStyle, configuration: POPickerStyleConfiguration

    // MARK: - View

    var body: some View {
        Menu {
            Group(poSubviews: configuration.content) { children in
                ForEach(children) { child in
                    Button {
                        configuration.selection = child.id
                    } label: {
                        child
                    }
                }
            }
        } label: {
            label(configuration: configuration)
        }
        .menuStyle(.borderlessButton)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let minHeight: CGFloat = 48
        static let padding = EdgeInsets(horizontal: POSpacing.medium, vertical: POSpacing.extraSmall)
    }

    // MARK: - Private Properties

    @Environment(\.isControlInvalid)
    private var isInvalid

    // MARK: - Private Methods

    @ViewBuilder
    private func label(configuration: POPickerStyleConfiguration) -> some View {
        let style = isInvalid ? inputStyle.error : inputStyle.normal
        HStack(spacing: POSpacing.small) {
            Group(poSubviews: configuration.content) { children in
                let selectedChild = children.first { child in
                    child.id == configuration.selection
                }
                if let selectedChild {
                    selectedChild.textStyle(style.text)
                } else {
                    Text(verbatim: "").textStyle(style.placeholder)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Image(poResource: .chevronDown)
                .renderingMode(.template)
                .foregroundColor(style.text.color)
        }
        .transaction { transaction in
            transaction.animation = nil
        }
        .lineLimit(1)
        .padding(Constants.padding)
        .frame(maxWidth: .infinity, minHeight: Constants.minHeight, alignment: .leading)
        .background(style.backgroundColor)
        .border(style: style.border)
        .shadow(style: style.shadow)
    }
}
