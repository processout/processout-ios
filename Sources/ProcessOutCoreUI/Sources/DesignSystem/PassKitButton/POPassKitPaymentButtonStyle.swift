//
//  POPassKitPaymentButtonStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 27.05.2024.
//

import PassKit

/// PassKit button style.
@available(iOS 14, *)
@MainActor
@preconcurrency
public struct POPassKitPaymentButtonStyle {

    /// Native style value.
    public let style: PKPaymentButtonStyle

    /// The radius, in points, for the rounded corners on the button.
    public let cornerRadius: CGFloat

    /// Creates style instance.
    public init(native: PKPaymentButtonStyle = .automatic) {
        self.style = native
        self.cornerRadius = POSpacing.extraSmall
    }

    /// Creates style instance.
    public init(native: PKPaymentButtonStyle = .automatic, cornerRadius: CGFloat) {
        self.style = native
        self.cornerRadius = cornerRadius
    }
}
