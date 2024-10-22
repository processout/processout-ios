//
//  View+ButtonRole.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.10.2024.
//

import SwiftUI

extension View {

    /// Sets the role of a button in the view's environment.
    ///
    /// - Parameter role: The button's role, or `nil` if unspecified.
    @_spi(PO)
    public func poButtonRole(_ role: POButtonRole?) -> some View {
        environment(\.poButtonRole, role)
    }
}

extension EnvironmentValues {

    /// The role of the button in the current environment.
    @_spi(PO)
    @Entry
    public var poButtonRole: POButtonRole?
}
