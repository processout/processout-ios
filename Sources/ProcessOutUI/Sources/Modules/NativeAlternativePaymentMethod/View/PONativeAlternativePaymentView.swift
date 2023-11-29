//
//  PONativeAlternativePaymentView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

/// View that allows user to pay with APM natively.
@available(iOS 14, *)
public struct PONativeAlternativePaymentView: View {

    init(viewModel: some NativeAlternativePaymentViewModel) {
        self._viewModel = .init(wrappedValue: .init(erasing: viewModel))
    }

    // MARK: - View

    public var body: some View {
        let backgroundColor = viewModel.isCaptured ? style.background.success : style.background.regular
        VStack(spacing: 0) {
            ScrollViewReader { scrollView in
                ScrollView(showsIndicators: false) {
                    // todo(andrii-vysotskyi): vertically center sections with inputs
                    VStack(alignment: .leading, spacing: POSpacing.medium) {
                        ForEach(viewModel.sections) { section in
                            NativeAlternativePaymentSectionView(
                                section: section, focusedInputId: $viewModel.focusedItemId
                            )
                        }
                    }
                    .padding(.vertical, POSpacing.large)
                }
                .backport.onChange(of: viewModel.focusedItemId) {
                    scrollToFocusedInput(scrollView: scrollView)
                }
                .animation(.default, value: contentAnimationValue)
                .clipped()
            }
            if !viewModel.actions.isEmpty {
                POActionsContainerView(actions: viewModel.actions).actionsContainerStyle(style.actionsContainer)
            }
        }
        .background(backgroundColor.ignoresSafeArea())
        .animation(.default, value: viewAnimationValue)
    }

    // MARK: - Private Properties

    @Environment(\.nativeAlternativePaymentStyle)
    private var style

    @StateObject
    private var viewModel: AnyNativeAlternativePaymentViewModel

    // MARK: - Private Methods

    private func scrollToFocusedInput(scrollView: ScrollViewProxy) {
        guard let id = viewModel.focusedItemId else {
            return
        }
        withAnimation { scrollView.scrollTo(id) }
    }

    /// Returns value that should trigger primary content animated update.
    private var contentAnimationValue: AnyHashable {
        viewModel.sections.map { [$0.id, $0.items.map(\.id), $0.error == nil] }
    }

    /// Returns value that should trigger whole view animated update.
    private var viewAnimationValue: AnyHashable {
        [AnyHashable(viewModel.actions.map(\.id)), viewModel.isCaptured]
    }
}
