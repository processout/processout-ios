//
//  POButtonRoleStyleProvider.swift
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
    public func buttonStyle(
        forPrimaryRole primaryStyle: any ButtonStyle, fallback fallbackStyle: any ButtonStyle
    ) -> some View {
        modifier(ContentModifier(primaryStyle: primaryStyle, fallbackStyle: fallbackStyle))
    }
}

private struct ContentModifier: ViewModifier {

    let primaryStyle, fallbackStyle: any ButtonStyle

    // MARK: - ViewModifier

    func body(content: Content) -> some View {
        let resolvedStyle = switch poButtonRole {
        case .primary:
            primaryStyle
        default:
            fallbackStyle
        }
        content.buttonStyle(POAnyButtonStyle(erasing: resolvedStyle))
    }

    // MARK: - Private Properties

    @Environment(\.poButtonRole)
    private var poButtonRole
}
