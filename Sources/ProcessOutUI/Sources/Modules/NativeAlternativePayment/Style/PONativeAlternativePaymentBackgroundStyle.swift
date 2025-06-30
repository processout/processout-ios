//
//  PONativeAlternativePaymentBackgroundStyle.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 23.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

/// Native alternative payment method screen background style.
@MainActor
@preconcurrency
@available(*, deprecated)
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

    /// Default native APM background style.
    @available(*, deprecated)
    public static let `default` = PONativeAlternativePaymentBackgroundStyle(
        regular: .Surface.primary, success: .Surface.successSubtle
    )
}
