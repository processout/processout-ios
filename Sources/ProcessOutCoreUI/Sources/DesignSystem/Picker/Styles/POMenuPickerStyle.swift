//
//  POMenuPickerStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 13.10.2023.
//

import SwiftUI

@_spi(PO) public struct POMenuPickerStyle: POPickerStyle {

    public init(inputStyle: POInputStyle = .medium) {
        self.inputStyle = inputStyle
    }

    public func makeBody(configuration: POPickerStyleConfiguration) -> some View {
        if #available(iOS 14.0, *) {
            makeMenu(configuration: configuration)
        } else {
            SheetMenu(label: label(configuration: configuration), configuration: configuration)
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let minHeight: CGFloat = 44
        static let padding = EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12)
    }

    // MARK: - Private Properties

    private let inputStyle: POInputStyle

    // MARK: - Private Methods

    @available(iOS 14.0, *)
    private func makeMenu(configuration: POPickerStyleConfiguration) -> some View {
        Menu {
            ForEach(configuration.elements) { element in
                Button(action: element.select, label: element.makeBody)
            }
        } label: {
            label(configuration: configuration)
        }
        .menuStyle(.borderlessButton)
    }

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
        .background(Color(style.backgroundColor))
        .border(style: style.border)
        .shadow(style: style.shadow)
    }
}

private struct SheetMenu<Label: View>: View {

    let label: Label
    let configuration: POPickerStyleConfiguration

    var body: some View {
        label
            .actionSheet(isPresented: $isSheetPresented) {
                let buttons: [ActionSheet.Button] = configuration.elements.map { element in
                    .default(element.makeBody(), action: element.select)
                }
                // todo(andrii-vysotskyi): replace with proper text when available
                return ActionSheet(title: Text(""), message: nil, buttons: buttons)
            }
            .onTapGesture {
                isSheetPresented = true
            }
    }

    // MARK: - Private Properties

    @State
    private var isSheetPresented = false
}

@_spi(PO) extension POPickerStyle where Self == POMenuPickerStyle {

    /// A picker style that presents the options as a menu when the user
    /// presses a button, or as a submenu when nested within a larger menu.
    public static var menu: POMenuPickerStyle {
        POMenuPickerStyle()
    }
}
