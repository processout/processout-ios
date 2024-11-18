//
//  POPicker.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 12.10.2023.
//

import SwiftUI

@_spi(PO)
@available(iOS 14, *)
@MainActor
public struct POPicker<Data: RandomAccessCollection, Id: Hashable>: View {

    // swiftlint:disable:next line_length
    public init(_ data: Data, selection: Binding<Id?>, content: @escaping (Data.Element) -> Text) where Data.Element: Identifiable, Data.Element.ID == Id {
        self.data = data
        self.id = \.id
        self._selection = selection
        self.content = content
    }

    public var body: some View {
        let configuration = POPickerStyleConfiguration(
            elements: data.map(createConfigurationElement), isInvalid: isInvalid
        )
        AnyView(style.makeBody(configuration: configuration))
    }

    // MARK: - Private Properties

    private let data: Data
    private let id: KeyPath<Data.Element, Id>
    private let content: (Data.Element) -> Text

    @Binding
    private var selection: Id?

    @Environment(\.pickerStyle)
    private var style

    @Environment(\.isControlInvalid)
    private var isInvalid

    // MARK: - Private Methods

    private func createConfigurationElement(element: Data.Element) -> POPickerStyleConfigurationElement {
        let element = POPickerStyleConfigurationElement(
            id: AnyHashable(element[keyPath: id]),
            makeBody: {
                content(element)
            },
            isSelected: selection == element[keyPath: id],
            select: {
                withAnimation {
                    selection = element[keyPath: id]
                }
            }
        )
        return element
    }
}
