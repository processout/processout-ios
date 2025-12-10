//
//  PONativeAlternativePaymentView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

/// View that allows user to pay with APM natively.
@MainActor
@preconcurrency
public struct PONativeAlternativePaymentView: View {

    init(viewModel: @autoclosure @escaping () -> some ViewModel<NativeAlternativePaymentViewModelState>) {
        self._viewModel = .init(wrappedValue: .init(erasing: viewModel()))
    }

    // MARK: - View

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical, showsIndicators: false) {
                NativeAlternativePaymentContentView(
                    viewModel: viewModel,
                    insets: .init(horizontal: POSpacing.space20, vertical: POSpacing.space12)
                )
            }
            if let controls = viewModel.state.controls, !controls.inline {
                POActionsContainerView(actions: controls.buttons)
                    .actionsContainerStyle(style.actionsContainer)
            }
        }
        .backport.background {
            style.backgroundColor.ignoresSafeArea()
        }
        .onAppear(perform: viewModel.start)
    }

    // MARK: - Private Properties

    @Environment(\.nativeAlternativePaymentStyle)
    private var style

    @StateObject
    private var viewModel: AnyViewModel<NativeAlternativePaymentViewModelState>
}
