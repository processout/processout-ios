//
//  POMenuPickerStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 13.10.2023.
//

import SwiftUI

@available(iOS 14, *)
@_spi(PO)
public struct POMenuPickerStyle: POPickerStyle {

    public init(inputStyle: POInputStyle) {
        self.inputStyle = inputStyle
    }

    public func makeBody(configuration: POPickerStyleConfiguration) -> some View {
        Menu {
            ForEach(configuration.elements) { element in
                Button(action: element.select, label: element.makeBody)
            }
        } label: {
            label(configuration: configuration)
        }
        .menuStyle(.borderlessButton)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let minHeight: CGFloat = 44
        static let padding = EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12)
    }

    // MARK: - Private Properties

    private let inputStyle: POInputStyle

    // MARK: - Private Methods

    @ViewBuilder
    private func label(configuration: POPickerStyleConfiguration) -> some View {
        let style = configuration.isInvalid ? inputStyle.error : inputStyle.normal
        Group {
            if let element = configuration.elements.first(where: \.isSelected) {
                element.makeBody().textStyle(style.text)
            } else {
                Text(verbatim: "").textStyle(style.placeholder)
            }
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

@available(iOS 14, *)
extension POPickerStyle where Self == POMenuPickerStyle {

    /// A picker style that presents the options as a menu when the user
    /// presses a button, or as a submenu when nested within a larger menu.
    public static var menu: POMenuPickerStyle {
        POMenuPickerStyle(inputStyle: .medium)
    }
}
