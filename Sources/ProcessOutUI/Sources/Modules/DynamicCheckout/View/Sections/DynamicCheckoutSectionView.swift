//
//  DynamicCheckoutSectionView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 21.03.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct DynamicCheckoutSectionView<ViewRouter>: View where ViewRouter: Router<DynamicCheckoutRoute> {

    let section: DynamicCheckoutViewModelSection
    let router: ViewRouter

    var body: some View {
        let horizontalPadding = section.areBezelsVisible ? POSpacing.small : 0
        VStack(spacing: POSpacing.small) {
            if let title = section.title, !title.isEmpty {
                Text(title)
                    .multilineTextAlignment(.center)
                    .onSizeChange { size in
                        titleSize = size
                    }
                    .padding(.horizontal, horizontalPadding)
            }
            let items = Array(
                section.items.enumerated()
            )
            ForEach(items, id: \.element.id) { offset, element in
                DynamicCheckoutItemView(item: element, router: router)
                if section.areSeparatorsVisible, offset + 1 < items.count {
                    Divider()
                }
            }
        }
        .padding(.vertical, section.areBezelsVisible ? POSpacing.small : 0)
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
            .padding(.top, hasTitle ? titleSize.height / 2 + POSpacing.small : 0)
    }
}
