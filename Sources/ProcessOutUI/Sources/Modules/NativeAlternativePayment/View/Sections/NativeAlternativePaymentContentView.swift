//
//  NativeAlternativePaymentContentView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 29.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct NativeAlternativePaymentContentView<ViewModel: NativeAlternativePaymentViewModel>: View {

    init(viewModel: ViewModel, horizontalPadding: CGFloat = POSpacing.large) {
        self.viewModel = viewModel
        self.horizontalPadding = horizontalPadding
    }

    // MARK: - View

    var body: some View {
        ScrollViewReader { scrollView in
            VStack(spacing: POSpacing.medium) {
                let partition = sectionsPartition
                ForEach(partition.top) { section in
                    NativeAlternativePaymentSectionView(
                        section: section, horizontalPadding: horizontalPadding, focusedItemId: $viewModel.focusedItemId
                    )
                }
                if !partition.center.isEmpty {
                    VStack(spacing: POSpacing.medium) {
                        ForEach(partition.center) { section in
                            NativeAlternativePaymentSectionView(
                                section: section,
                                horizontalPadding: horizontalPadding,
                                focusedItemId: $viewModel.focusedItemId
                            )
                        }
                    }
                    .backport.geometryGroup()
                    .frame(maxHeight: .infinity)
                }
            }
            .backport.onChange(of: viewModel.focusedItemId) {
                scrollToFocusedInput(scrollView: scrollView)
            }
            .padding(.vertical, POSpacing.medium)
            .frame(maxWidth: .infinity)
        }
        .backport.geometryGroup()
    }

    // MARK: - Private Properties

    private let horizontalPadding: CGFloat

    @ObservedObject
    private var viewModel: ViewModel

    // swiftlint:disable:next line_length
    private var sectionsPartition: (top: [NativeAlternativePaymentViewModelSection], center: [NativeAlternativePaymentViewModelSection]) {
        let sections = viewModel.sections
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

    // MARK: - Private Methods

    private func shouldCenter(item: NativeAlternativePaymentViewModelItem) -> Bool {
        switch item {
        case .title, .submitted:
            return false
        default:
            return true
        }
    }

    private func scrollToFocusedInput(scrollView: ScrollViewProxy) {
        guard let id = viewModel.focusedItemId else {
            return
        }
        withAnimation { scrollView.scrollTo(id) }
    }
}
