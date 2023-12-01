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
        VStack(spacing: 0) {
            GeometryReader { geometry in
                ScrollViewReader { scrollView in
                    ScrollView(showsIndicators: false) {
                        NativeAlternativePaymentSectionsView(
                            sections: viewModel.sections, focusedItemId: $viewModel.focusedItemId
                        )
                        .backport.geometryGroup()
                        .frame(minHeight: geometry.size.height, alignment: .top)
                    }
                    .backport.onChange(of: viewModel.focusedItemId) {
                        scrollToFocusedInput(scrollView: scrollView)
                    }
                    .clipped()
                }
            }
            if !viewModel.actions.isEmpty {
                POActionsContainerView(actions: viewModel.actions)
                    .actionsContainerStyle(style.actionsContainer)
                    .layoutPriority(1)
            }
        }
        .backport.background {
            let backgroundColor = viewModel.isCaptured ? style.background.success : style.background.regular
            backgroundColor
                .ignoresSafeArea()
                .animation(.default, value: viewModel.isCaptured)
        }
        .animation(.default, value: viewModel.actions.count)
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
}
