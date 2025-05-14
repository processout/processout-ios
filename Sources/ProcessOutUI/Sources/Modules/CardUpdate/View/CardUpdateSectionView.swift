//
//  CardUpdateSectionView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 17.01.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
@MainActor
struct CardUpdateSectionView: View {

    let section: CardUpdateViewModelSection

    @Binding
    private(set) var focusedInputId: AnyHashable?

    var body: some View {
        VStack(alignment: .leading, spacing: POSpacing.small) {
            if let title = section.title {
                Text(title).textStyle(style.sectionTitle)
            }
            ForEach(section.items) { element in
                CardUpdateItemView(item: element, focusedInputId: $focusedInputId)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .backport.geometryGroup()
    }

    // MARK: - Private Properties

    @Environment(\.cardUpdateStyle)
    private var style
}
