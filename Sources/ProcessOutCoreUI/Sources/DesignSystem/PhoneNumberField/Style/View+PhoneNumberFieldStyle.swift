//
//  View+PhoneNumberFieldStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.05.2025.
//

import SwiftUI

extension View {

    /// Sets the style for phone number fields within this view.
    @available(iOS 14, *)
    @_spi(PO)
    public func phoneNumberFieldStyle(_ style: any POPhoneNumberFieldStyle) -> some View {
        environment(\.phoneNumberFieldStyle, style)
    }
}

@available(iOS 14, *)
extension EnvironmentValues {

    /// The style to apply to phone number fields.
    @_spi(PO)
    @MainActor
    public internal(set) var phoneNumberFieldStyle: any POPhoneNumberFieldStyle {
        get { self[Key.self] ?? .automatic }
        set { self[Key.self] = newValue }
    }

    private struct Key: EnvironmentKey {
        static let defaultValue: (any POPhoneNumberFieldStyle)? = nil
    }
}
