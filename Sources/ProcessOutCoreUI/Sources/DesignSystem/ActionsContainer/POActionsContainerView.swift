//
//  POActionsContainerView.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 20.10.2023.
//

import SwiftUI

@_spi(PO)
@available(iOS 14, *)
@MainActor
public struct POActionsContainerView: View {

    public init(actions: [POButtonViewModel]) {
        self.actions = actions
    }

    public var body: some View {
        if !actions.isEmpty {
            VStack(spacing: POSpacing.small) {
                ForEach(actions) { element in
                    Button.create(with: element)
                        .buttonStyle(forPrimaryRole: style.primary, fallback: style.secondary)
                }
                .modify(when: style.axis == .horizontal) { content in
                    // The implementation considers that benign action that people are likely to
                    // want is first and when the axis is horizontal and layout direction is LTR,
                    // we want it to be placed on the right.
                    HStack(spacing: POSpacing.small) {
                        content.environment(\.layoutDirection, layoutDirection)
                    }
                    .environment(\.layoutDirection, layoutDirection == .leftToRight ? .rightToLeft : .leftToRight)
                }
            }
            .padding(POSpacing.large)
            .overlay(
                Rectangle()
                    .fill(style.separatorColor)
                    .frame(height: 1)
                    .frame(maxHeight: .infinity, alignment: .top)
            )
            .background(
                style.backgroundColor.ignoresSafeArea()
            )
            .backport.geometryGroup()
            .animation(.default, value: actions.map(\.id))
        }
    }

    // MARK: - Private Properties

    private let actions: [POButtonViewModel]

    @Environment(\.actionsContainerStyle)
    private var style

    @Environment(\.layoutDirection)
    private var layoutDirection
}
