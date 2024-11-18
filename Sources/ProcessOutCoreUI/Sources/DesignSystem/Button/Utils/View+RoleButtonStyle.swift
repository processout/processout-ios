//
//  View+RoleButtonStyle.swift.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.10.2024.
//

import SwiftUI

// todo(andrii-vysotskyi): PO button style(s) should be able to respond to role environment automatically

extension View {

    /// Applies a button style based on the button's role.
    ///
    /// - Parameters:
    ///   - primaryStyle: The style for the primary role.
    ///   - fallbackStyle: The style used when the role is not primary.
    @_spi(PO)
    @MainActor
    public func buttonStyle(
        forPrimaryRole primaryStyle: any ButtonStyle, fallback fallbackStyle: any ButtonStyle
    ) -> some View {
        self.buttonStyle(RoleButtonStyle(primaryStyle: primaryStyle, fallbackStyle: fallbackStyle))
    }
}

@MainActor
private struct RoleButtonStyle: ButtonStyle {

    let primaryStyle, fallbackStyle: any ButtonStyle

    // MARK: - ButtonStyle

    func makeBody(configuration: Configuration) -> some View {
        let resolvedStyle = switch poButtonRole {
        case .primary:
            primaryStyle
        default:
            fallbackStyle
        }
        AnyView(resolvedStyle.makeBody(configuration: configuration))
    }

    // MARK: - Private Properties

    @Environment(\.poButtonRole)
    private var poButtonRole
}
