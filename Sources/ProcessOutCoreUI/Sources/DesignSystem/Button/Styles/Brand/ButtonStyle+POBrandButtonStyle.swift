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
            title: .init(color: Color(poResource: .Text.primary), typography: .button),
            border: .clear,
            shadow: .clear
        )
    }
}
