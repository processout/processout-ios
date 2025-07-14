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

    init(viewModel: AnyViewModel<NativeAlternativePaymentViewModelState>, insets: EdgeInsets) {
        self.viewModel = viewModel
        self.insets = insets
    }

    // MARK: - View

    var body: some View {
        ScrollViewReader { scrollView in
            VStack(spacing: POSpacing.space16) {
                ForEach(viewModel.state.items) { item in
                    NativeAlternativePaymentItemView(item: item, focusedItemId: $viewModel.state.focusedItemId)
                        .padding(.init(top: 0, leading: insets.leading, bottom: 0, trailing: insets.trailing))
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
                if let controls = viewModel.state.controls, controls.inline {
                    VStack(spacing: POSpacing.space12) {
                        ForEach(controls.buttons) { button in
                            Button.create(with: button).buttonStyle(
                                forPrimaryRole: style.actionsContainer.primary,
                                fallback: style.actionsContainer.secondary
                            )
                        }
                    }
                    .padding(
                        .init(top: POSpacing.space12, leading: insets.leading, bottom: 0, trailing: insets.trailing)
                    )
                }
            }
            .padding(
                .init(top: insets.top, leading: 0, bottom: insets.bottom, trailing: 0)
            )
            .backport.onChange(of: viewModel.state.focusedItemId) {
                scrollToFocusedInput(scrollView: scrollView)
            }
            .backport.geometryGroup()
        }
        .backport.geometryGroup()
        .poConfirmationDialog(item: $viewModel.state.confirmationDialog)
    }

    // MARK: - Private Properties

    private let insets: EdgeInsets

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
