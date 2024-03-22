//
//  PODynamicCheckoutPaymentStyle.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 22.03.2024.
//

@_spi(PO) import ProcessOutCoreUI

public struct PODynamicCheckoutPaymentStyle {

    /// Title style.
    public var title = POTextStyle(color: .orange, typography: .Medium.title)

    /// Information text style.
    public var informationText = POTextStyle(color: .green, typography: .Fixed.body)
}
