//
//  POLabeledContentStyle+Automatic.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.06.2025.
//

import SwiftUI

@available(iOS 14, *)
extension POLabeledContentStyle where Self == POAutomaticLabeledContentStyle {

    /// A labeled content style that resolves its appearance automatically based
    /// on the current context.
    public static var automatic: POAutomaticLabeledContentStyle {
        POAutomaticLabeledContentStyle(
            primaryTextStyle: .init(
                color: Color.Input.Placeholder.default,
                typography: POTypography.Text.s12(weight: .medium)
            ),
            secondaryTextStyle: .init(
                color: Color.Text.primary,
                typography: POTypography.Text.s15(weight: .medium)
            )
        )
    }
}
