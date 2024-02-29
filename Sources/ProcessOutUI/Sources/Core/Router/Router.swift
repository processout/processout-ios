//
//  Router.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 28.02.2024.
//

import SwiftUI

protocol Router<Route> {

    /// Type describing possible routes.
    associatedtype Route: Hashable

    /// Content.
    associatedtype Content: View

    /// Creates view for give route.
    @ViewBuilder func view(for route: Route) -> Content
}
