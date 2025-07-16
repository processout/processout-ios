//
//  PONativeAlternativePaymentConfirmationProgressViewStyle+Automatic.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.06.2025.
//

import SwiftUI
import ProcessOutCoreUI

extension PONativeAlternativePaymentConfirmationProgressViewStyle
    where Self == POAutomaticNativeAlternativePaymentConfirmationProgressViewStyle<POStepProgressViewStyle, POMultistepProgressGroupBoxStyle> { // swiftlint:disable:this line_length

    /// Default progress view style.
    public static var automatic: some PONativeAlternativePaymentConfirmationProgressViewStyle {
        POAutomaticNativeAlternativePaymentConfirmationProgressViewStyle()
    }
}
