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
        VStack(spacing: POSpacing.small) {
            if let title = section.title, !title.isEmpty {
                Text(title)
                    .multilineTextAlignment(.center)
                    .onSizeChange { size in
                        titleSize = size
                    }
            }
            let sectionItems = Array(section.items.enumerated())
            ForEach(sectionItems, id: \.element.id) { offset, element in
                DynamicCheckoutItemView(item: element)
                if section.areSeparatorsVisible, offset + 1 < sectionItems.count {
                    Divider()
                }
            }
        }
        .padding(POSpacing.small)
        .frame(maxWidth: .infinity)
        .overlay(borderOverlay)
    }

    // MARK: - Private Properties

    @State
    private var titleSize: CGSize = .zero

    // MARK: - Private Methods

    @ViewBuilder
    private var borderOverlay: some View {
        let hasTitle = min(titleSize.width, titleSize.height) > 0
        Color.clear
            .border(
                POTrimmedRoundedRectangle(
                    gapWidth: hasTitle ? titleSize.width + POSpacing.small * 2 : 0
                ),
                style: .regular(color: .black)
            )
            .padding(.top, hasTitle ? titleSize.height / 2 + POSpacing.small : 0)
    }
}
