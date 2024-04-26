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
struct DynamicCheckoutContentView<ViewRouter>: View where ViewRouter: Router<DynamicCheckoutRoute> {

    let sections: [DynamicCheckoutViewModelSection]
    let router: ViewRouter

    // MARK: - View

    var body: some View {
        VStack(spacing: POSpacing.medium) {
            let sections = Array(
                sections.enumerated()
            )
            ForEach(sections, id: \.element.id) { offset, element in
                DynamicCheckoutSectionView(section: element, router: router)
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
        .backport.geometryGroup()
    }

    // MARK: - Private Properties

    @Environment(\.dynamicCheckoutStyle)
    private var style
}
