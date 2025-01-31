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
public struct POPicker<SelectionValue: Hashable, Content: View>: View {

    public init(selection: Binding<SelectionValue?>, @ViewBuilder content: () -> Content) {
        self._selection = selection
        self.content = content()
    }

    public var body: some View {
        let selection = Binding<AnyHashable?> {
            self.selection
        } set: { newValue in
            self.selection = newValue?.base as? SelectionValue
        }
        let configuration = POPickerStyleConfiguration(selection: selection) {
            content
        }
        AnyView(style.makeBody(configuration: configuration))
    }

    // MARK: - Private Properties

    private let content: Content

    @Binding
    private var selection: SelectionValue?

    @Environment(\.pickerStyle)
    private var style
}
