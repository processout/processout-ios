//
//  LabeledDivider.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 19.04.2024.
//

import SwiftUI

/// Only horizontal layout is supported at a moment.
@_spi(PO)
public struct POLabeledDivider: View {

    public init(title: String) {
        self.title = title
    }

    public var body: some View {
        HStack(spacing: POSpacing.small) {
            divider
            Text(title)
                .textStyle(style.title)
            divider
        }
    }

    // MARK: - Private Properties

    private let title: String

    @Environment(\.labeledDividerStyle)
    private var style

    // MARK: - Private Methods

    private var divider: some View {
        // Divider is placed inside a VStack to make it horizontal when added to HStack.
        VStack {
            Divider().background(style.color)
        }
    }
}
