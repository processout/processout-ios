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

    let section: DynamicCheckoutViewModelState.Section

    var body: some View {
        VStack(spacing: section.isTight ? 0 : POSpacing.small) {
            let items = Array(section.items.enumerated())
            ForEach(items, id: \.element.id) { offset, item in
                VStack(spacing: 0) {
                    if section.areBezelsVisible, offset != 0 {
                        Divider()
                            .frame(height: style.regularPaymentMethod.border.width)
                            .overlay(style.regularPaymentMethod.border.color)
                    }
                    DynamicCheckoutItemView(item: item)
                        .padding(section.areBezelsVisible ? POSpacing.large : 0)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .background(background(for: item))
                .backport.geometryGroup()
            }
        }
        .border(style: section.areBezelsVisible ? style.regularPaymentMethod.border : .clear)
        .backport.geometryGroup()
    }

    // MARK: - Private Properties

    @Environment(\.dynamicCheckoutStyle)
    private var style

    // MARK: - Private Methods

    @ViewBuilder
    private func background(for item: DynamicCheckoutViewModelState.Item) -> some View {
        if !section.areBezelsVisible {
            style.backgroundColor.opacity(0)
        } else if case .regularPayment(let item) = item, !item.info.isSelectable {
            style.regularPaymentMethod.disabledBackgroundColor
        } else {
            style.backgroundColor
        }
    }
}
