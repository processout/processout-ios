//
//  PONativeAlternativePaymentBackgroundStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 23.05.2023.
//

import UIKit

/// Native alternative payment method screen background style.
@available(*, deprecated, message: "Use ProcessOutUI.PONativeAlternativePaymentBackgroundStyle instead.")
public struct PONativeAlternativePaymentMethodBackgroundStyle {

    /// Regular background color.
    public let regular: UIColor

    /// Background color to use in case of success.
    public let success: UIColor

    /// Creates background style instance.
    public init(regular: UIColor? = nil, success: UIColor? = nil) {
        self.regular = regular ?? UIColor(resource: .Surface.level1)
        self.success = success ?? UIColor(resource: .Surface.success)
    }
}
