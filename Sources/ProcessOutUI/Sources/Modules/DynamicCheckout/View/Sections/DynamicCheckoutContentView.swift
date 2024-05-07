//
//  DynamicCheckoutContentView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 19.04.2024.
//

import SwiftUI
@_spi(PO) import ProcessOut
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct DynamicCheckoutContentView: View {

    let sections: [DynamicCheckoutViewModelSection]

    // MARK: - View

    var body: some View {
        VStack(spacing: POSpacing.small) {
            let sections = Array(
                sections.enumerated()
            )
            ForEach(sections, id: \.element.id) { offset, element in
                DynamicCheckoutSectionView(section: element)
                    .frame(maxWidth: .infinity)
                if offset + 1 < sections.count {
                    POLabeledDivider(
                        title: String(resource: .DynamicCheckout.Section.divider)
                    )
                    .labeledDividerStyle(style.section.divider)
                }
            }
        }
        .padding(POSpacing.medium)
        .frame(maxWidth: .infinity)
        .backport.geometryGroup()
    }

    // MARK: - Private Properties

    @Environment(\.dynamicCheckoutStyle)
    private var style
}
