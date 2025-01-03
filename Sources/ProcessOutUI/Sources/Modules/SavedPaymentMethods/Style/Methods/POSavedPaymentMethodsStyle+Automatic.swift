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
            toolbar: .init(
                title: POTextStyle(color: Color(poResource: .Text.primary), typography: .title),
                dividerColor: Color(poResource: .Border.subtle),
                backgroundColor: Color(poResource: .Surface.default)
            ),
            content: .init(
                border: .regular(color: Color(poResource: .Border.subtle)),
                dividerColor: Color(poResource: .Border.subtle)
            ),
            progressView: .circular,
            cancelButton: .ghost,
            backgroundColor: Color(poResource: .Surface.default)
        )
    }
}
