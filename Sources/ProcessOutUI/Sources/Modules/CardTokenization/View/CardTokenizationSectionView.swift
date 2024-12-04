//
//  CardTokenizationSectionView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 19.10.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
@MainActor
struct CardTokenizationSectionView: View {

    let section: CardTokenizationViewModelState.Section

    @Binding
    private(set) var focusedInputId: AnyHashable?

    var body: some View {
        VStack(alignment: .leading, spacing: POSpacing.small) {
            if let title = section.title {
                Text(title)
                    .textStyle(style.sectionTitle)
            }
            ForEach(section.items) { element in
                CardTokenizationItemView(item: element, focusedInputId: $focusedInputId)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .backport.geometryGroup()
    }

    // MARK: - Private Properties

    @Environment(\.cardTokenizationStyle)
    private var style
}
