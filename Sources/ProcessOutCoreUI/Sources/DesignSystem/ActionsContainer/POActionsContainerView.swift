//
//  POActionsContainerView.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 20.10.2023.
//

import SwiftUI

@_spi(PO) public struct POActionsContainerView: View {

    public init(actions: [POActionsContainerActionViewModel], spacing: CGFloat, horizontalPadding: CGFloat) {
        self.actions = actions
        self.spacing = spacing
        self.horizontalPadding = horizontalPadding
    }

    public var body: some View {
        container {
            Divider()
                .frame(height: 1)
                .overlay(Color(style.separatorColor))
            ForEach(actions) { element in
                Button(element.title, action: element.action)
                    .buttonStyle(POAnyButtonStyle(erasing: element.isPrimary ? style.primary : style.secondary))
                    .disabled(!element.isEnabled)
                    .buttonLoading(element.isLoading)
                    .accessibility(identifier: element.id)
            }
            .padding(.horizontal, horizontalPadding)
        }
        .padding(.bottom, spacing)
        .background(Color(style.backgroundColor).edgesIgnoringSafeArea(.all))
    }

    // MARK: - Private Properties

    private let actions: [POActionsContainerActionViewModel]
    private let spacing: CGFloat
    private let horizontalPadding: CGFloat

    @Environment(\.actionsContainerStyle) private var style

    // MARK: - Private Methods

    /// Wraps given in a container that lays out items based on axis defined in style.
    @ViewBuilder
    private func container<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        switch style.axis {
        case .horizontal:
            HStack(spacing: spacing, content: content)
        case .vertical:
            VStack(spacing: spacing, content: content)
        }
    }
}
