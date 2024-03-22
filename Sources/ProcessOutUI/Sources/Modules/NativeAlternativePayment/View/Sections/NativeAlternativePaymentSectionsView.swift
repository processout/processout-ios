//
//  NativeAlternativePaymentSectionsView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 29.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct NativeAlternativePaymentSectionsView: View {

    let sections: [NativeAlternativePaymentViewModelSection]

    @Binding
    private(set) var focusedItemId: AnyHashable?

    var body: some View {
        VStack(spacing: POSpacing.medium) {
            let partition = sectionsPartition
            ForEach(partition.top) { section in
                NativeAlternativePaymentSectionView(section: section, focusedItemId: $focusedItemId)
            }
            if !partition.center.isEmpty {
                VStack(spacing: POSpacing.medium) {
                    ForEach(partition.center) { section in
                        NativeAlternativePaymentSectionView(section: section, focusedItemId: $focusedItemId)
                    }
                }
                .backport.geometryGroup()
                .frame(maxHeight: .infinity)
            }
        }
        .padding(.vertical, POSpacing.medium)
        .animation(.default, value: bodyAnimationValue)
    }

    // MARK: - Animation

    /// Returns value that should trigger whole body animated update.
    private var bodyAnimationValue: AnyHashable {
        sections.map { section in
            [section.id, section.items.map(animationValue), section.error]
        }
    }

    private func animationValue(item: NativeAlternativePaymentViewModelItem) -> AnyHashable {
        switch item {
        case .title(let titleItem):
            return titleItem
        case .submitted(let submittedItem):
            return submittedItem
        default:
            return item.id
        }
    }

    // MARK: - Partition

    // swiftlint:disable:next line_length
    private var sectionsPartition: (top: [NativeAlternativePaymentViewModelSection], center: [NativeAlternativePaymentViewModelSection]) {
        let index = sections.firstIndex { section in
            section.items.contains(where: shouldCenter)
        }
        guard let index else {
            return (top: sections, center: [])
        }
        let top = Array(sections.prefix(upTo: index))
        let center = Array(sections.suffix(from: index))
        return (top, center)
    }

    private func shouldCenter(item: NativeAlternativePaymentViewModelItem) -> Bool {
        switch item {
        case .title, .submitted:
            return false
        default:
            return true
        }
    }
}
