//
//  DynamicCheckoutSectionView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 21.03.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
@MainActor
struct DynamicCheckoutSectionView: View {

    let section: DynamicCheckoutViewModelState.Section

    var body: some View {
        VStack(spacing: section.isTight ? 0 : POSpacing.small) {
            let items = Array(section.items.enumerated())
            ForEach(items, id: \.element.id) { offset, item in
                VStack(spacing: 0) {
                    if section.areBezelsVisible, offset != 0 {
                        Rectangle()
                            .fill(style.regularPaymentMethod.border.color)
                            .frame(height: style.regularPaymentMethod.border.width)
                            .frame(maxWidth: .infinity)
                    }
                    DynamicCheckoutItemView(item: item)
                        .padding(section.areBezelsVisible ? POSpacing.large : 0)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .background(
                    style.regularPaymentMethod.backgroundColor.opacity(section.areBezelsVisible ? 1 : 0)
                )
                .backport.geometryGroup()
            }
        }
        .border(style: section.areBezelsVisible ? style.regularPaymentMethod.border : .clear)
        .backport.geometryGroup()
    }

    // MARK: - Private Properties

    @Environment(\.dynamicCheckoutStyle)
    private var style
}
