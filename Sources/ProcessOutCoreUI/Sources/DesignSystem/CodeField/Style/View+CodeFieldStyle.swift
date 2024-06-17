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
    func codeFieldStyle(_ style: some CodeFieldStyle) -> some View {
        environment(\.codeFieldStyle, AnyCodeFieldStyle(erasing: style))
    }
}

@available(iOS 14.0, *)
extension EnvironmentValues {

    var codeFieldStyle: AnyCodeFieldStyle {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Properties

    private struct Key: EnvironmentKey {
        static let defaultValue = AnyCodeFieldStyle(erasing: .default)
    }
}
