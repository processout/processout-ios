//
//  BlockRouter.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 26.04.2024.
//

import SwiftUI

final class BlockRouter<Route: Hashable, Content: View>: Router {

    init(content: @escaping (Route) -> Content) {
        self.content = content
    }

    // MARK: - Router

    func view(for route: Route) -> Content {
        content(route)
    }

    // MARK: - Private Properties

    private let content: (Route) -> Content
}
