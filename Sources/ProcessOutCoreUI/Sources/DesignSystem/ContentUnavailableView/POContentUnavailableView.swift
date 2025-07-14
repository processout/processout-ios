//
//  POContentUnavailableView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.01.2025.
//

import SwiftUI

@_spi(PO)
@MainActor
public struct POContentUnavailableView<Label: View, Description: View>: View {

    public init(@ViewBuilder label: () -> Label, @ViewBuilder description: () -> Description = { EmptyView() }) {
        self.label = label()
        self.description = description()
    }

    // MARK: - View

    public var body: some View {
        let configuration = POContentUnavailableViewStyleConfiguration {
            label
        } description: {
            description
        }
        AnyView(style.makeBody(configuration: configuration))
    }

    // MARK: - Private Properties

    private let label: Label
    private let description: Description

    @Environment(\.poContentUnavailableViewStyle)
    private var style
}
