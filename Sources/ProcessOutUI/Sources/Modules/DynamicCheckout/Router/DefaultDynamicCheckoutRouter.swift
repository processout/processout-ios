//
//  DefaultDynamicCheckoutRouter.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

import SwiftUI

@available(iOS 14, *)
struct DefaultDynamicCheckoutRouter: Router {

    init(delegate: DynamicCheckoutRouterDelegate) {
        self.delegate = delegate
    }

    // MARK: - Router

    func view(for route: DynamicCheckoutRoute) -> some View {
        switch route {
        case .card:
            if let interactor = delegate?.routerWillRouteToCardTokenization(self) {
                POCardTokenizationView(interactor: interactor)
            }
        case .nativeAlternativePayment(let id):
            if let interactor = delegate?.router(self, willRouteToNativeAlternativePaymentWith: id) {
                PONativeAlternativePaymentView(interactor: interactor)
            }
        }
    }

    // MARK: - Private Properties

    private weak var delegate: DynamicCheckoutRouterDelegate?
}
