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
struct DynamicCheckoutView<ViewModel: DynamicCheckoutViewModel, ViewRouter>: View
    where ViewRouter: Router<DynamicCheckoutRoute> {

    init(viewModel: ViewModel, router: ViewRouter) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.router = router
    }

    // MARK: - View

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                DynamicCheckoutSectionsView(sections: viewModel.sections, router: router)
            }
            .clipped()
            .frame(maxHeight: .infinity)
            if !viewModel.actions.isEmpty {
                POActionsContainerView(actions: viewModel.actions)
                    .actionsContainerStyle(style.actionsContainer)
            }
        }
        .background(
            style.backgroundColor.ignoresSafeArea()
        )
        .backport.geometryGroup()
    }

    // MARK: - Private Properties

    private let router: ViewRouter

    @StateObject
    private var viewModel: ViewModel

    @Environment(\.dynamicCheckoutStyle)
    private var style
}
