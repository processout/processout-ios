//
//  View+PhoneNumberFieldTerritories.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.05.2025.
//

import SwiftUI

extension View {

    /// Sets the size for controls within this view.
    @_spi(PO)
    @ViewBuilder
    public func phoneNumberFieldTerritories(_ territories: [POPhoneNumber.Territory]) -> some View {
        environment(\.phoneNumberFieldTerritories, territories)
    }
}

extension EnvironmentValues {

    /// Phone number territories available for user to select.
    @_spi(PO)
    public internal(set) var phoneNumberFieldTerritories: [POPhoneNumber.Territory]? {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    private struct Key: EnvironmentKey {
        static let defaultValue: [POPhoneNumber.Territory]? = nil
    }
}
