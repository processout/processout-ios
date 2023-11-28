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
    private(set) var focusedInputId: AnyHashable?

    var body: some View {
        VStack(alignment: .leading, spacing: POSpacing.small) {
            if let title = section.title {
                Text(title)
                    .textStyle(style.sectionTitle)
                    .padding(.horizontal, POSpacing.large)
            }
            ForEach(section.items) { element in
                NativeAlternativePaymentItemView(item: element, focusedInputId: $focusedInputId)
            }
            if let error = section.error {
                Text(error)
                    .textStyle(style.errorDescription)
                    .padding(.horizontal, POSpacing.large)
            }
        }
        .backport.geometryGroup()
    }

    // MARK: - Private Properties

    @Environment(\.nativeAlternativePaymentStyle)
    private var style
}
