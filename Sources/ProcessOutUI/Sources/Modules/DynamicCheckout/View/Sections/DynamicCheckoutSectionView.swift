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
        .border(style: section.areBezelsVisible ? style.section.border : .clear)
        .backport.geometryGroup()
    }

    // MARK: - Private Properties

    @Environment(\.dynamicCheckoutStyle)
    private var style
}
