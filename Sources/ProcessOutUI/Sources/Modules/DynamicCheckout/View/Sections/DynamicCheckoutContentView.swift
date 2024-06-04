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
        VStack(spacing: POSpacing.large) {
            ForEach(sections) { section in
                DynamicCheckoutSectionView(section: section).frame(maxWidth: .infinity)
            }
        }
        .padding(
            .init(top: POSpacing.large, leading: POSpacing.medium, bottom: POSpacing.medium, trailing: POSpacing.medium)
        )
        .frame(maxWidth: .infinity)
        .backport.geometryGroup()
    }

    // MARK: - Private Properties

    @Environment(\.dynamicCheckoutStyle)
    private var style
}
