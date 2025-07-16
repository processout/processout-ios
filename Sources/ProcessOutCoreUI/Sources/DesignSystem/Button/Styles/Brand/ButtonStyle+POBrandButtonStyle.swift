//
//  ButtonStyle+POBrandButtonStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 24.04.2024.
//

import SwiftUI

extension ButtonStyle where Self == POBrandButtonStyle {

    /// Simple style that changes its appearance based on brand color ``SwiftUICore/EnvironmentValues/poButtonBrandColor``.
    @_disfavoredOverload
    @MainActor
    @preconcurrency
    public static var brand: POBrandButtonStyle {
        POBrandButtonStyle(
            title: .init(
                color: .Text.primary, typography: .Text.s15(weight: .medium)
            ),
            border: .button(color: .clear),
            shadow: .clear,
            progressStyle: CircularProgressViewStyle(tint: .Text.primary)
        )
    }
}
