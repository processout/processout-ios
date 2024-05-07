//
//  DynamicCheckoutSectionView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 21.03.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct DynamicCheckoutSectionView: View {

    let section: DynamicCheckoutViewModelSection

    var body: some View {
        VStack(spacing: 0) {
            if let title = section.title, !title.isEmpty {
                Text(title)
                    .textStyle(style.title)
                    .multilineTextAlignment(.center)
                    .onSizeChange { size in
                        titleSize = size
                    }
                    .padding(.horizontal, POSpacing.small)
            }
            VStack(spacing: section.areSeparatorsVisible ? 0 : POSpacing.small) {
                let items = Array(
                    section.items.enumerated()
                )
                ForEach(items, id: \.element.id) { offset, element in
                    DynamicCheckoutItemView(item: element)
                    if section.areSeparatorsVisible, offset + 1 < items.count {
                        Divider()
                            .frame(height: 1)
                            .overlay(style.subsection.dividerColor)
                    }
                }
            }
            .padding(section.areSeparatorsVisible ? 0 : POSpacing.medium)
        }
        .overlay(borderOverlay)
        .backport.geometryGroup()
    }

    // MARK: - Private Properties

    @State
    private var titleSize: CGSize = .zero

    @Environment(\.dynamicCheckoutStyle)
    private var style

    // MARK: - Private Methods

    @ViewBuilder
    private var borderOverlay: some View {
        let hasTitle = min(titleSize.width, titleSize.height) > 0
        Color.clear
            .border(
                POTrimmedRoundedRectangle(
                    gapWidth: hasTitle ? titleSize.width + POSpacing.small * 2 : 0
                ),
                style: section.areBezelsVisible ? style.section.border : .clear
            )
            .padding(.top, hasTitle ? titleSize.height / 2 : 0)
    }
}
