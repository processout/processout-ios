//
//  View+FontFeatures.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 30.07.2024.
//

import SwiftUI

extension View {

    /// - WARNING: This method allows to modify text style that is applied later on
    /// with ````SwiftUI/View/textStyle(_:addPadding:)`` modifier.
    @_spi(PO)
    public func fontFeatures(_ settings: POFontFeaturesSettings) -> some View {
        environment(\.fontFeatures, settings)
    }

    /// - WARNING: This method allows to modify text style that is applied later on
    /// with ````SwiftUI/View/textStyle(_:addPadding:)`` modifier.
    @_spi(PO)
    public func fontNumberSpacing(_ fontNumberSpacing: POFontNumberSpacing) -> some View {
        environment(\.fontFeatures.numberSpacing, fontNumberSpacing)
    }
}

extension EnvironmentValues {

    var fontFeatures: POFontFeaturesSettings {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Properties

    private struct Key: EnvironmentKey {
        static let defaultValue = POFontFeaturesSettings()
    }
}
