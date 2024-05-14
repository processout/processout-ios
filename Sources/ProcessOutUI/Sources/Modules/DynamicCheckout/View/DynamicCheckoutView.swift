//
//  DynamicCheckoutView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 28.02.2024.
//

import SwiftUI
@_spi(PO) import ProcessOut
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct DynamicCheckoutView<ViewModel: DynamicCheckoutViewModel>: View {

    init(viewModel: @autoclosure @escaping () -> ViewModel) {
        self._viewModel = .init(wrappedValue: viewModel())
    }

    // MARK: - View

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { scrollView in
                ScrollView(showsIndicators: true) {
                    DynamicCheckoutContentView(sections: viewModel.state.sections)
                        .scrollViewProxy(scrollView)
                }
                .backport.geometryGroup()
            }
            .clipped()
            if !viewModel.state.actions.isEmpty {
                POActionsContainerView(actions: viewModel.state.actions)
                    .actionsContainerStyle(style.actionsContainer)
            }
        }
        .backport.background {
            let backgroundColor = viewModel.state.isCompleted ? style.success.backgroundColor : style.backgroundColor
            backgroundColor
                .ignoresSafeArea()
                .animation(.default, value: viewModel.state.isCompleted)
        }
        .onAppear(perform: viewModel.start)
        .backport.geometryGroup()
    }

    // MARK: - Private Properties

    @StateObject
    private var viewModel: ViewModel

    @Environment(\.dynamicCheckoutStyle)
    private var style
}
