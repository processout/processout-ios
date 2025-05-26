//
//  PhoneNumberFieldStyleConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.05.2025.
//

import SwiftUI

@_spi(PO)
public struct POPhoneNumberFieldStyleConfiguration {

    /// Country..
    public let country: AnyView

    /// Number.
    public let number: AnyView

    init(@ViewBuilder country: () -> some View, @ViewBuilder number: () -> some View) {
        self.country = AnyView(country())
        self.number = AnyView(number())
    }
}
