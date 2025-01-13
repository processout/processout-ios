//
//  POContentUnavailableViewStyleConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.01.2025.
//

import SwiftUI

/// The properties of a content unavailable view.
@MainActor
public struct POContentUnavailableViewStyleConfiguration {

    /// The label that describes the view.
    public let label: AnyView

    /// The view that describes the interface.
    public let description: AnyView

    init(@ViewBuilder label: () -> some View, @ViewBuilder description: () -> some View) {
        self.label = AnyView(label())
        self.description = AnyView(description())
    }
}
