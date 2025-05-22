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
                title: POTextStyle(color: Color.Text.primary, typography: .Text.s20(weight: .medium)),
                dividerColor: Color.Border.primary,
                backgroundColor: Color.Surface.primary
            ),
            content: .init(
                border: .regular(color: Color.Border.primary),
                dividerColor: Color.Border.primary
            ),
            progressView: .circular,
            messageView: .toast,
            cancelButton: .ghost,
            backgroundColor: Color.Surface.primary
        )
    }
}
