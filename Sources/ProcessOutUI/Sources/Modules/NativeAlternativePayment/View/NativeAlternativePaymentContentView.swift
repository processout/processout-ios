//
//  NativeAlternativePaymentContentView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 29.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
@MainActor
struct NativeAlternativePaymentContentView: View {

    init(viewModel: AnyViewModel<NativeAlternativePaymentViewModelState>, insets: CGFloat) {
        self.viewModel = viewModel
        self.insets = insets
    }

    // MARK: - View

    var body: some View {
        ScrollViewReader { scrollView in
            VStack(spacing: POSpacing.space16) {
                ForEach(viewModel.state.items) { item in
                    NativeAlternativePaymentItemView(item: item, focusedItemId: $viewModel.state.focusedItemId)
                        .padding(.horizontal, insets)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .overlayPreferenceValue(
                            NativeAlternativePaymentViewSeparatorVisibilityPreferenceKey.self,
                            alignment: .bottom,
                            { isVisible in
                                separatorView(isVisible: isVisible)
                            }
                        )
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.vertical, insets)
            .backport.onChange(of: viewModel.state.focusedItemId) {
                scrollToFocusedInput(scrollView: scrollView)
            }
            .backport.geometryGroup()
        }
        .backport.geometryGroup()
        .poConfirmationDialog(item: $viewModel.state.confirmationDialog)
    }

    // MARK: - Private Properties

    private let insets: CGFloat

    @Environment(\.nativeAlternativePaymentSizeClass)
    private var sizeClass

    @Environment(\.nativeAlternativePaymentStyle)
    private var style

    @ObservedObject
    private var viewModel: AnyViewModel<NativeAlternativePaymentViewModelState>

    // MARK: - Private Methods

    @ViewBuilder
    private func separatorView(isVisible: Bool) -> some View {
        if isVisible {
            Rectangle()
                .fill(style.separatorColor)
                .frame(height: 1)
                .frame(maxWidth: .infinity)
        }
    }

    private func scrollToFocusedInput(scrollView: ScrollViewProxy) {
        guard let id = viewModel.state.focusedItemId else {
            return
        }
        withAnimation { scrollView.scrollTo(id) }
    }
}
