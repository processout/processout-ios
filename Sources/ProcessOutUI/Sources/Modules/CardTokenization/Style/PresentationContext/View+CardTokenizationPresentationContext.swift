//
//  View+CardTokenizationPresentationContext.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 21.07.2025.
//

import SwiftUI

extension View {

    /// Sets card tokenization presentation context.
    public func cardTokenizationPresentationContext(_ context: POCardTokenizationPresentationContext) -> some View {
        environment(\.cardTokenizationPresentationContext, context)
    }
}

extension EnvironmentValues {

    @Entry
    var cardTokenizationPresentationContext: POCardTokenizationPresentationContext = .standalone
}
