//
//  POMenuPickerStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 13.10.2023.
//

import SwiftUI

@_spi(PO)
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

extension POPickerStyle where Self == POMenuPickerStyle {

    /// A picker style that presents the options as a menu when the user
    /// presses a button, or as a submenu when nested within a larger menu.
    public static var menu: POMenuPickerStyle {
        POMenuPickerStyle(inputStyle: .medium)
    }
}

@MainActor
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
        static let padding = EdgeInsets(
            top: POSpacing.space6, leading: POSpacing.space12, bottom: POSpacing.space6, trailing: POSpacing.space16
        )
        static let minHeight: CGFloat = 52
    }

    // MARK: - Private Properties

    @Environment(\.isControlInvalid)
    private var isInvalid

    @Environment(\.poControlWidth)
    private var poControlWidth

    // MARK: - Private Methods

    @ViewBuilder
    private func label(configuration: POPickerStyleConfiguration) -> some View {
        let style = isInvalid ? inputStyle.error : inputStyle.normal
        HStack(spacing: POSpacing.space8) {
            Group(poSubviews: configuration.content) { children in
                let selectedChild = children.first { child in
                    child.id == configuration.selection
                }
                FloatingValue(
                    isFloating: configuration.selection != nil,
                    spacing: POSpacing.space2,
                    animation: nil,
                    value: {
                        ViewThatExists {
                            configuration.currentValueLabel
                                .textStyle(style.text)
                            if let selectedChild {
                                selectedChild
                                    .textStyle(style.text)
                            }
                        }
                    },
                    placeholder: { isFloating in
                        configuration.prompt
                            .textStyle(style.label.scaledBy(isFloating ? 0.8 : 1))
                            .fixedSize()
                    }
                )
            }
            .frame(maxWidth: maxWidth, alignment: .leading)
            Image(poResource: .chevronDown)
                .renderingMode(.template)
                .foregroundColor(style.text.color)
        }
        .transaction { transaction in
            transaction.animation = nil
        }
        .lineLimit(1)
        .padding(Constants.padding)
        .frame(maxWidth: maxWidth, minHeight: Constants.minHeight, alignment: .leading)
        .background(style.backgroundColor)
        .border(style: style.border)
        .shadow(style: style.shadow)
    }

    private var maxWidth: CGFloat? {
        let widths: [POControlWidth: CGFloat] = [.expanded: .infinity]
        return widths[poControlWidth]
    }
}

@available(iOS 17, *)
#Preview {
    @Previewable @State var value: String?
    POPicker(selection: $value) {
        Text("Hello").id("1")
        Text("World").id("2")
    } prompt: {
        Text("Placeholder")
    }
    .pickerStyle(POMenuPickerStyle(inputStyle: .medium))
    .padding()
}
