//
//  NativeAlternativePaymentSectionView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct NativeAlternativePaymentSectionView: View {

    let section: NativeAlternativePaymentViewModelSection

    @Binding
    private(set) var focusedItemId: AnyHashable?

    var body: some View {
        let alignment: Alignment = section.isCentered ? .center : .leading
        VStack(alignment: alignment.horizontal, spacing: POSpacing.small) {
            if let title = section.title {
                Text(title)
                    .textStyle(style.sectionTitle)
                    .padding(.horizontal, POSpacing.large)
            }
            ForEach(section.items) { element in
                NativeAlternativePaymentItemView(item: element, focusedItemId: $focusedItemId)
            }
            if let error = section.error {
                Text(error)
                    .textStyle(style.errorDescription)
                    .padding(.horizontal, POSpacing.large)
            }
        }
        .multilineTextAlignment(section.isCentered ? .center : .leading)
        .frame(maxWidth: .infinity, alignment: alignment)
        .backport.geometryGroup()
    }

    // MARK: - Private Properties

    @Environment(\.nativeAlternativePaymentStyle)
    private var style
}
