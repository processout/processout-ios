//
//  DynamicCheckoutView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 28.02.2024.
//

import SwiftUI

@available(iOS 14, *)
struct DynamicCheckoutView<ViewModel: DynamicCheckoutViewModel, ViewRouter: Router>: View
    where ViewRouter.Route == DynamicCheckoutRoute {

    init(viewModel: ViewModel, router: ViewRouter) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.router = router
    }

    // MARK: - View

    var body: some View {
        EmptyView()
    }

    // MARK: - Private Properties

    private let router: ViewRouter

    @StateObject
    private var viewModel: ViewModel
}
