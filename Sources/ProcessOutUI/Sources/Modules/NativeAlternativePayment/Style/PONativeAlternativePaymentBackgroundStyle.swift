//
//  PONativeAlternativePaymentBackgroundStyle.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 23.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

/// Native alternative payment method screen background style.
public struct PONativeAlternativePaymentBackgroundStyle {

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

extension PONativeAlternativePaymentBackgroundStyle {

    /// Default native APM background style.
    public static let `default` = PONativeAlternativePaymentBackgroundStyle(
        regular: Color(.Surface.default), success: Color(.Surface.success)
    )
}
