//
//  EnvironmentValues+ButtonBrandColor.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 24.04.2024.
//

import SwiftUI

extension View {

    /// Adds a condition that controls whether button with a `POButtonStyle` should show loading indicator.
    @_spi(PO) public func buttonBrandColor(_ color: UIColor) -> some View {
        environment(\.poButtonBrandColor, color)
    }
}

extension EnvironmentValues {

    /// Brand color of associated third party service. Only ``POBrandButtonStyle`` responds to this property changes.
    public var poButtonBrandColor: UIColor {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Nested Types

    private struct Key: EnvironmentKey {
        static let defaultValue = UIColor(poResource: .Button.Primary.Background.default)
    }
}
