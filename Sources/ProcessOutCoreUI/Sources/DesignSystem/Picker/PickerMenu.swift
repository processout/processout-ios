//
//  PickerMenu.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.09.2023.
//

import SwiftUI

public struct PickerMenu<Data: RandomAccessCollection, Id: Hashable>: View {

    // swiftlint:disable:next line_length
    init(_ data: Data, selection: Binding<Data.Element>, content: @escaping (Data.Element) -> Text) where Data.Element == Id {
        self.data = data
        elementId = \.self
        self._selection = selection
        self.content = content
    }

    public var body: some View {
        let currentStyle = stateStyle()
        if #available(iOS 14, *) {
            Menu {
                ForEach(data, id: elementId) { element in
                    Button { selection = element } label: { content(element) }
                }
            } label: {
                label(element: selection, style: currentStyle)
            }
            .menuStyle(.borderlessButton)
            .animation(.default, value: inError)
        } else {
            label(element: selection, style: currentStyle)
                .actionSheet(isPresented: $isActionSheetPresented) {
                    let buttons: [ActionSheet.Button] = data.map { element in
                        .default(content(element), action: { selection = element })
                    }
                    return ActionSheet(title: Text("Please select option"), message: nil, buttons: buttons)
                }
                .onTapGesture {
                    isActionSheetPresented = true
                }
        }
    }

    // MARK: - Nested Types

    // MARK: - Private Properties

    private let data: Data
    private let elementId: KeyPath<Data.Element, Id>
    private let content: (Data.Element) -> Text

    @Binding
    private var selection: Data.Element

    @State
    private var isActionSheetPresented = false

    @Environment(\.pickerMenuStyle) private var style
    @Environment(\.pickerMenuError) private var inError

    // MARK: - Private Methods

    private func stateStyle() -> POInputStateStyle {
        inError ? style.error : style.normal
    }

    private func label(element: Data.Element, style: POInputStateStyle) -> some View {
        content(element)
            .textStyle(style.text)
            .lineLimit(1)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, idealHeight: 44, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .background(Color(style.backgroundColor))
            .border(style: style.border)
            .shadow(style: style.shadow)
    }
}

extension View {

    public func pickerMenuStyle(_ style: POInputStyle) -> some View {
        environment(\.pickerMenuStyle, style)
    }

    public func pickerMenuError(_ inError: Bool) -> some View {
        environment(\.pickerMenuError, inError)
    }
}

extension EnvironmentValues {

    var pickerMenuStyle: POInputStyle {
        get { self[StyleKey.self] }
        set { self[StyleKey.self] = newValue }
    }

    var pickerMenuError: Bool {
        get { self[ErrorKey.self] }
        set { self[ErrorKey.self] = newValue }
    }

    // MARK: - Private Nested Types

    private struct StyleKey: EnvironmentKey {
        static let defaultValue = POInputStyle.default()
    }

    private struct ErrorKey: EnvironmentKey {
        static let defaultValue = false
    }
}
