//
//  PONativeAlternativePaymentMethodUiConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.11.2022.
//

import Foundation

/// A configuration object that defines how a native alternative payment view controller content's.
/// Use `nil` to indicate that default value should be used.
public struct PONativeAlternativePaymentMethodUiConfiguration {

    /// Custom title.
    public let title: String?

    /// Custom success message to display user when payment completes.
    public let successMessage: String?

    /// Primary action text. Such as "Pay".
    public let primaryActionTitle: String?

    public init(title: String? = nil, successMessage: String? = nil, primaryActionTitle: String? = nil) {
        self.title = title
        self.successMessage = successMessage
        self.primaryActionTitle = primaryActionTitle
    }
}
