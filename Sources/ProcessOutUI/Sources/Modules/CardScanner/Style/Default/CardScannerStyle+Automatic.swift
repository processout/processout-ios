//
//  CardScannerStyle+Automatic.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.12.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
extension POCardScannerStyle where Self == PODefaultCardScannerStyle {

    /// The default card scanner style.
    public static var automatic: PODefaultCardScannerStyle {
        PODefaultCardScannerStyle(
            title: POTextStyle(color: Color(poResource: .Text.primary), typography: .body1),
            description: POTextStyle(color: Color(poResource: .Text.muted), typography: .body2),
            torchToggle: POButtonToggleStyle(buttonStyle: .ghost),
            videoPreview: .init(
                backgroundColor: .black,
                border: .init(radius: POSpacing.small, width: 0, color: .clear),
                overlayColor: .black.opacity(0.4)
            ),
            card: .init(
                number: .init(color: Color(poResource: .Text.primary), typography: .extraLargeTitle),
                cardholderName: .init(color: Color(poResource: .Text.primary), typography: .body3),
                expiration: .init(color: Color(poResource: .Text.primary), typography: .body3),
                border: .init(radius: POSpacing.small, width: 1, color: Color(poResource: .Text.inverse))
            ),
            cancelButton: .secondary,
            backgroundColor: Color(poResource: .Surface.default)
        )
    }
}
