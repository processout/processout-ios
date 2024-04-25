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
                        NativeAlternativePaymentContentView(scrollView: scrollView, viewModel: viewModel)
                            .frame(minHeight: geometry.size.height, alignment: .top)
                    }
                    .clipped()
                }
            }
            if !viewModel.actions.isEmpty {
                POActionsContainerView(actions: viewModel.actions)
                    .actionsContainerStyle(style.actionsContainer)
            }
        }
        .backport.background {
            let backgroundColor = viewModel.isCaptured ? style.background.success : style.background.regular
            backgroundColor
                .ignoresSafeArea()
                .animation(.default, value: viewModel.isCaptured)
        }
    }

    // MARK: - Private Properties

    @Environment(\.nativeAlternativePaymentStyle)
    private var style

    @StateObject
    private var viewModel: AnyNativeAlternativePaymentViewModel
}
