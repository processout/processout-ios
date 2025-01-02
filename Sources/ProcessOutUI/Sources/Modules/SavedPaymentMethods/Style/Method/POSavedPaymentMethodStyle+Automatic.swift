//
//  POSavedPaymentMethodStyle+Automatic.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.12.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
extension POSavedPaymentMethodStyle where Self == PODefaultSavedPaymentMethodStyle {

    /// The default saved payment method style.
    public static var automatic: PODefaultSavedPaymentMethodStyle {
        PODefaultSavedPaymentMethodStyle(
            description: POTextStyle(color: Color(poResource: .Text.primary), typography: .button),
            deleteButton: .ghost(titleColor: Color(poResource: .Text.error))
        )
    }
}
