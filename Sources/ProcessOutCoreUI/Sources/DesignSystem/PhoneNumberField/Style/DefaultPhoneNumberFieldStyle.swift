//
//  DefaultPhoneNumberFieldStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.05.2025.
//

import SwiftUI

@_spi(PO)
@available(iOS 14, *)
public struct PODefaultPhoneNumberFieldStyle<Country: POPickerStyle, Number: POTextFieldStyle>
    : POPhoneNumberFieldStyle {

    public init(country: Country, number: Number) {
        self.country = country
        self.number = number
    }

    // MARK: - POPhoneNumberFieldStyle

    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: POSpacing.extraSmall) {
            configuration.country
                .pickerStyle(country)
                .controlWidth(.regular)
            configuration.number
                .poTextFieldStyle(number)
        }
    }

    // MARK: - Private Properties

    private let country: Country, number: Number
}
