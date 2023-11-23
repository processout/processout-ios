//
//  PONativeAlternativePaymentMethodBackgroundStyle.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 23.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

/// Native alternative payment method screen background style.
public struct PONativeAlternativePaymentMethodBackgroundStyle {

    /// Regular background color.
    public let regular: Color

    /// Background color to use in case of success.
    public let success: Color

    /// Creates background style instance.
    public init(regular: Color, success: Color) {
        self.regular = regular
        self.success = success
    }
}

extension PONativeAlternativePaymentMethodBackgroundStyle {

    /// Default card tokenization style.
    public static let `default` = PONativeAlternativePaymentMethodBackgroundStyle(
        regular: Color(poResource: .Surface.level1), success: Color(poResource: .Surface.success)
    )
}
