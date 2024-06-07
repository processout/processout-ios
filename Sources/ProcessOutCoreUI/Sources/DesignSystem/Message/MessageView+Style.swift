//
//  MessageView+Style.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 03.06.2024.
//

import SwiftUI

extension View {

    /// Sets the style for picker views within this view.
    @_spi(PO)
    @available(iOS 14.0, *)
    public func messageViewStyle(_ style: any POMessageViewStyle) -> some View {
        environment(\.messageViewStyle, AnyMessageViewStyle(erasing: style))
    }
}

@available(iOS 14.0, *)
extension EnvironmentValues {

    var messageViewStyle: AnyMessageViewStyle {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Properties

    private struct Key: EnvironmentKey {
        static let defaultValue = AnyMessageViewStyle(erasing: .toast)
    }
}
