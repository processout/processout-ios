//
//  View+CodeFieldStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 13.06.2024.
//

import SwiftUI

extension View {

    /// Sets the style for picker views within this view.
    @available(iOS 14.0, *)
    func codeFieldStyle(_ style: any CodeFieldStyle) -> some View {
        environment(\.codeFieldStyle, style)
    }
}

@available(iOS 14.0, *)
extension EnvironmentValues {

    var codeFieldStyle: any CodeFieldStyle {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Properties

    @MainActor
    private struct Key: @preconcurrency EnvironmentKey {
        static let defaultValue: any CodeFieldStyle = .default
    }
}
