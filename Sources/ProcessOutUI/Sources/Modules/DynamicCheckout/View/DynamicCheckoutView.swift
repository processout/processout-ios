//
//  DynamicCheckoutView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 28.02.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct DynamicCheckoutView<ViewModel: DynamicCheckoutViewModel, ViewRouter: Router>: View
    where ViewRouter.Route == DynamicCheckoutRoute {

    init(viewModel: ViewModel, router: ViewRouter) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.router = router
    }

    // MARK: - View

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: POSpacing.medium) {
                    let sections = Array(viewModel.sections.enumerated())
                    ForEach(sections, id: \.element.id) { offset, element in
                        DynamicCheckoutSectionView(section: element, router: router)
                        if offset + 1 < sections.count {
                            DynamicCheckoutSectionSeparatorView()
                        }
                    }
                }
                .padding(.vertical, POSpacing.medium)
                .backport.geometryGroup() // todo(andrii-vysotskyi): add animation
            }
            .clipped()
            if !viewModel.actions.isEmpty {
                POActionsContainerView(actions: viewModel.actions)
                    .actionsContainerStyle(style.actionsContainer)
            }
        }
        .background(style.backgroundColor)
        .animation(.default, value: viewModel.actions.count)
    }

    // MARK: - Private Properties

    private let router: ViewRouter

    @StateObject
    private var viewModel: ViewModel

    @Environment(\.dynamicCheckoutStyle)
    private var style
}
