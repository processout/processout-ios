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
@MainActor
@preconcurrency
public struct PONativeAlternativePaymentView: View {

    init(viewModel: @autoclosure @escaping () -> AnyViewModel<NativeAlternativePaymentViewModelState>) {
        self._viewModel = .init(wrappedValue: viewModel())
    }

    // MARK: - View

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            NativeAlternativePaymentContentView(viewModel: viewModel, insets: POSpacing.space20)
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
