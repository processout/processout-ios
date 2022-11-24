//
//  PONativeAlternativePaymentMethodConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.11.2022.
//

import Foundation

public struct PONativeAlternativePaymentMethodConfiguration {

    /// Custom title.
    public let title: String??

    /// Formatter to use when converting currencies to strings.
    public let currencyFormatter: NumberFormatter?
}
