//
//  PONativeAlternativePaymentSuccessViewStyle+Automatic.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.06.2025.
//

import SwiftUI
import ProcessOutCoreUI

@available(iOS 14.0, *)
extension PONativeAlternativePaymentSuccessViewStyle where Self == POAutomaticNativeAlternativePaymentSuccessViewStyle {

    /// Default payment success view style.
    public static var automatic: some PONativeAlternativePaymentSuccessViewStyle {
        POAutomaticNativeAlternativePaymentSuccessViewStyle()
    }
}
