//
//  POActionsContainerView.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 20.10.2023.
//

import SwiftUI

@available(iOS 14, *)
@_spi(PO)
public struct POActionsContainerView: View {

    public init(actions: [POActionsContainerActionViewModel], spacing: CGFloat, horizontalPadding: CGFloat) {
        self.actions = actions
        self.spacing = spacing
        self.horizontalPadding = horizontalPadding
    }

    public var body: some View {
        VStack(spacing: spacing) {
            Divider()
                .frame(height: 1)
                .overlay(style.separatorColor)
            ForEach(actions) { element in
                Button(element.title, action: element.action)
                    .buttonStyle(POAnyButtonStyle(erasing: element.isPrimary ? style.primary : style.secondary))
                    .disabled(!element.isEnabled)
                    .buttonLoading(element.isLoading)
                    .accessibility(identifier: element.id)
            }
            .modify(when: style.axis == .horizontal) { content in
                // The implementation considers that benign action that people are likely to
                // want is first and when the axis is horizontal and layout direction is LTR,
                // we want it to be placed on the right.
                HStack(spacing: spacing) {
                    content.environment(\.layoutDirection, layoutDirection)
                }
                .environment(\.layoutDirection, layoutDirection == .leftToRight ? .rightToLeft : .leftToRight)
            }
            .padding(.horizontal, horizontalPadding)
        }
        .padding(.bottom, spacing)
        .background(
            style.backgroundColor.ignoresSafeArea()
        )
        .backport.geometryGroup()
        .animation(.default, value: actions.map(\.id))
    }

    // MARK: - Private Properties

    private let actions: [POActionsContainerActionViewModel]
    private let spacing: CGFloat
    private let horizontalPadding: CGFloat

    @Environment(\.actionsContainerStyle) private var style
    @Environment(\.layoutDirection) private var layoutDirection
}
