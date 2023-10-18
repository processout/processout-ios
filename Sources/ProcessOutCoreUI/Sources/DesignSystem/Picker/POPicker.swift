//
//  POPicker.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 12.10.2023.
//

import SwiftUI

@_spi(PO) public struct POPicker<Data: RandomAccessCollection, Id: Hashable>: View {

    // swiftlint:disable:next line_length
    public init(_ data: Data, selection: Binding<Data.Element?>, content: @escaping (Data.Element) -> Text) where Data.Element == Id {
        self.data = data
        self.id = \.self
        self._selection = selection
        self.content = content
    }

    // swiftlint:disable:next line_length
    public init(_ data: Data, id: KeyPath<Data.Element, Id>, selection: Binding<Data.Element?>, content: @escaping (Data.Element) -> Text) {
        self.data = data
        self.id = id
        self._selection = selection
        self.content = content
    }

    public var body: some View {
        let configuration = POPickerStyleConfiguration(
            elements: data.map(createConfigurationElement), isInvalid: isInvalid
        )
        style.makeBody(configuration: configuration)
    }

    // MARK: - Private Properties

    private let data: Data
    private let id: KeyPath<Data.Element, Id>
    private let content: (Data.Element) -> Text

    @Binding private var selection: Data.Element?

    @Environment(\.pickerStyle) private var style
    @Environment(\.isControlInvalid) private var isInvalid

    // MARK: - Private Methods

    private func createConfigurationElement(element: Data.Element) -> POPickerStyleConfigurationElement {
        let element = POPickerStyleConfigurationElement(
            id: AnyHashable(element[keyPath: id]),
            makeBody: {
                content(element)
            },
            isSelected: selection?[keyPath: id] == element[keyPath: id],
            select: {
                withAnimation {
                    selection = element
                }
            }
        )
        return element
    }
}
