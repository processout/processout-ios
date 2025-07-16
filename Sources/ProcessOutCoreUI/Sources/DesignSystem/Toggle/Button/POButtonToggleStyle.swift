//
//  POButtonToggleStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.12.2024.
//

import SwiftUI

/// Toggle style that uses a Button to represent the toggle's behavior, styled with a
/// user-provided ButtonStyle
@MainActor
public struct POButtonToggleStyle: ToggleStyle {

    public init(buttonStyle: some ButtonStyle) {
        self.buttonStyle = buttonStyle
    }

    // MARK: - ToggleStyle

    public func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.$isOn.wrappedValue.toggle()
        } label: {
            configuration.label
        }
        .buttonStyle(POAnyButtonStyle(erasing: buttonStyle))
        .controlSelected(configuration.isOn)
    }

    // MARK: - Private Properties

    private let buttonStyle: any ButtonStyle
}
