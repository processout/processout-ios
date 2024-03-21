//
//  DefaultDynamicCheckoutRouter.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

import SwiftUI

struct DefaultDynamicCheckoutRouter: Router {

    /// Configuration.
    let configuration: PODynamicCheckoutConfiguration

    func view(for route: DynamicCheckoutRoute) -> some View {
        // todo(andrii-vysotskyi): configure routes to actual views
        EmptyView()
    }
}
