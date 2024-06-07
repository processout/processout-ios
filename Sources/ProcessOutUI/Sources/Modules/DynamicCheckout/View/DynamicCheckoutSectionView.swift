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
                        .padding(section.areBezelsVisible ? POSpacing.medium : 0)
                }
                .background(section.areBezelsVisible ? style.backgroundColor : .clear)
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
