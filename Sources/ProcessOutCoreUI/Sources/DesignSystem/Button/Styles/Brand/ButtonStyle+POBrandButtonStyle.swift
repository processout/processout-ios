//
//  ButtonStyle+POBrandButtonStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 24.04.2024.
//

import SwiftUI

@available(iOS 14, *)
extension ButtonStyle where Self == POBrandButtonStyle {

    /// Simple style that changes its appearance based on brand color ``SwiftUICore/EnvironmentValues/poButtonBrandColor``.
    @_disfavoredOverload
    @MainActor
    @preconcurrency
    public static var brand: POBrandButtonStyle {
        POBrandButtonStyle(
            title: .init(
                color: Color(poResource: .Button.Primary.Title.default),
                typography: .Text.s14(weight: .medium)
            ),
            border: .clear,
            shadow: .clear,
            progressStyle: CircularProgressViewStyle(tint: Color(poResource: .Button.Primary.Title.default))
        )
    }
}
