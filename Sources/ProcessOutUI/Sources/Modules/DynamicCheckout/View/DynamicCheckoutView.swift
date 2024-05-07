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
                    DynamicCheckoutContentView(sections: viewModel.sections)
                        .scrollViewProxy(scrollView)
                }
            }
            .clipped()
            if !viewModel.actions.isEmpty {
                POActionsContainerView(actions: viewModel.actions)
                    .actionsContainerStyle(style.actionsContainer)
            }
        }
        .background(
            style.backgroundColor.ignoresSafeArea()
        )
        .onAppear(perform: viewModel.start)
        .backport.geometryGroup()
    }

    // MARK: - Private Properties

    @StateObject
    private var viewModel: ViewModel

    @Environment(\.dynamicCheckoutStyle)
    private var style
}
