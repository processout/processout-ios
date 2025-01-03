//
//  POSavedPaymentMethodsStyle+Automatic.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.12.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
extension POSavedPaymentMethodsStyle where Self == PODefaultSavedPaymentMethodsStyle {

    /// The default saved payment method style.
    public static var automatic: PODefaultSavedPaymentMethodsStyle {
        PODefaultSavedPaymentMethodsStyle(
            title: POTextStyle(color: Color(poResource: .Text.primary), typography: .title),
            border: .regular(color: Color(poResource: .Border.subtle)),
            progressView: .circular
        )
    }
}
