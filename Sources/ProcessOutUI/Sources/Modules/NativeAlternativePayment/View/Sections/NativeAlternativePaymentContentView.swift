//
//  NativeAlternativePaymentContentView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 29.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct NativeAlternativePaymentContentView: View {

    init(
        viewModel: AnyViewModel<NativeAlternativePaymentViewModelState>,
        insets: EdgeInsets,
        shouldCenterParameters: Bool = true
    ) {
        self.viewModel = viewModel
        self.insets = insets
        self.shouldCenterParameters = shouldCenterParameters
    }

    // MARK: - View

    var body: some View {
        ScrollViewReader { scrollView in
            VStack(spacing: POSpacing.medium) {
                let partition = sectionsPartition
                ForEach(partition.top) { section in
                    NativeAlternativePaymentSectionView(
                        section: section,
                        horizontalPadding: max(insets.leading, insets.trailing),
                        focusedItemId: $viewModel.state.focusedItemId
                    )
                }
                if !partition.center.isEmpty {
                    VStack(spacing: POSpacing.medium) {
                        ForEach(partition.center) { section in
                            NativeAlternativePaymentSectionView(
                                section: section,
                                horizontalPadding: max(insets.leading, insets.trailing),
                                focusedItemId: $viewModel.state.focusedItemId
                            )
                        }
                    }
                    .backport.geometryGroup()
                    .frame(maxHeight: .infinity)
                }
            }
            .backport.onChange(of: viewModel.state.focusedItemId) {
                scrollToFocusedInput(scrollView: scrollView)
            }
            .padding(EdgeInsets(top: insets.top, leading: 0, bottom: insets.bottom, trailing: 0))
            .frame(maxWidth: .infinity)
        }
        .backport.geometryGroup()
    }

    // MARK: - Private Properties

    private let insets: EdgeInsets
    private let shouldCenterParameters: Bool

    @ObservedObject
    private var viewModel: AnyViewModel<NativeAlternativePaymentViewModelState>

    // swiftlint:disable:next line_length
    private var sectionsPartition: (top: [NativeAlternativePaymentViewModelSection], center: [NativeAlternativePaymentViewModelSection]) {
        let sections = viewModel.state.sections
        guard shouldCenterParameters else {
            return (top: sections, center: [])
        }
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
        guard let id = viewModel.state.focusedItemId else {
            return
        }
        withAnimation { scrollView.scrollTo(id) }
    }
}
