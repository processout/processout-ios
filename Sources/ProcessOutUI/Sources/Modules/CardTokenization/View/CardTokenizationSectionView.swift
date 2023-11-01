//
//  CardTokenizationSectionView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 19.10.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct CardTokenizationSectionView: View {

    let section: CardTokenizationViewModelState.Section

    /// The distance between adjacent items.
    let spacing: CGFloat

    @Binding
    private(set) var focusedInputId: AnyHashable?

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            if let title = section.title {
                Text(title).textStyle(style.sectionTitle)
            }
            ForEach(section.items) { element in
                CardTokenizationItemView(item: element, spacing: spacing, focusedInputId: $focusedInputId)
            }
        }
        .backport.geometryGroup()
    }

    // MARK: - Private Properties

    @Environment(\.cardTokenizationStyle)
    private var style
}
