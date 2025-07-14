//
//  CardScannerStyle+Automatic.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.12.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

extension POCardScannerStyle where Self == PODefaultCardScannerStyle {

    /// The default card scanner style.
    public static var automatic: PODefaultCardScannerStyle {
        PODefaultCardScannerStyle(
            title: POTextStyle(
                color: Color.Text.primary, typography: .Text.s16(weight: .medium)
            ),
            description: POTextStyle(
                color: Color.Text.secondary, typography: .Text.s14()
            ),
            torchToggle: POButtonToggleStyle(buttonStyle: .ghost),
            videoPreview: .init(
                backgroundColor: .black,
                border: .init(radius: 8, width: 0, color: .clear),
                overlayColor: .black.opacity(0.4)
            ),
            card: .init(
                number: .init(
                    color: Color.Text.primary, typography: .Text.s24()
                ),
                cardholderName: .init(
                    color: Color.Text.primary, typography: .Text.s16()
                ),
                expiration: .init(
                    color: Color.Text.primary, typography: .Text.s16()
                ),
                border: .init(radius: 8, width: 1, color: Color.Text.inverse)
            ),
            cancelButton: .secondary,
            backgroundColor: Color.Surface.primary
        )
    }
}
