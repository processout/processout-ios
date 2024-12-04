//
//  NativeAlternativePaymentSectionView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
@MainActor
struct NativeAlternativePaymentSectionView: View {

    let section: NativeAlternativePaymentViewModelSection
    let horizontalPadding: CGFloat

    @Binding
    private(set) var focusedItemId: AnyHashable?

    var body: some View {
        let alignment: Alignment = section.isCentered ? .center : .leading
        VStack(alignment: alignment.horizontal, spacing: POSpacing.small) {
            if let title = section.title {
                Text(title)
                    .textStyle(style.sectionTitle)
                    .padding(.horizontal, horizontalPadding)
            }
            ForEach(section.items) { element in
                NativeAlternativePaymentItemView(
                    item: element, horizontalPadding: horizontalPadding, focusedItemId: $focusedItemId
                )
            }
            if let error = section.error {
                Text(error)
                    .textStyle(style.errorDescription)
                    .padding(.horizontal, horizontalPadding)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .multilineTextAlignment(section.isCentered ? .center : .leading)
        .frame(maxWidth: .infinity, alignment: alignment)
        .backport.geometryGroup()
    }

    // MARK: - Private Properties

    @Environment(\.nativeAlternativePaymentStyle)
    private var style
}
