//
//  Router.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 19.03.2024.
//

import SwiftUI

protocol Router<Content, Route> {

    /// Route type that the router manages.
    associatedtype Route: Hashable

    /// The type of view representing the content of this router.
    associatedtype Content: View

    /// The content and behavior of the view for given route.
    func view(for route: Route) -> Content
}
