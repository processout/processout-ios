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

    init(viewModel: @autoclosure @escaping () -> AnyViewModel<NativeAlternativePaymentViewModelState>) {
        self._viewModel = .init(wrappedValue: viewModel())
    }

    // MARK: - View

    public var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    NativeAlternativePaymentContentView(viewModel: viewModel, insets: POSpacing.large)
                        .frame(minHeight: geometry.size.height, alignment: .top)
                }
                .clipped()
            }
            POActionsContainerView(actions: viewModel.state.actions)
                .actionsContainerStyle(style.actionsContainer)
        }
        .backport.background {
            let backgroundColor = viewModel.state.isCaptured ? style.background.success : style.background.regular
            backgroundColor
                .ignoresSafeArea()
                .animation(.default, value: viewModel.state.isCaptured)
        }
        .onAppear(perform: viewModel.start)
        .onDisappear(perform: viewModel.stop)
    }

    // MARK: - Private Properties

    @Environment(\.nativeAlternativePaymentStyle)
    private var style

    @StateObject
    private var viewModel: AnyViewModel<NativeAlternativePaymentViewModelState>
}
