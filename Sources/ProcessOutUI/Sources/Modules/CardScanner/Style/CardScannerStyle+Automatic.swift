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
            videoPreview: .init(
                backgroundColor: Color(poResource: .Button.Primary.Background.default),
                border: .init(radius: POSpacing.small, width: 0, color: .clear)
            ),
            cancelButton: .secondary
        )
    }
}
