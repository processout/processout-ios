//
//  PODefaultSavedPaymentMethodStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.12.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

/// The default card scanner style.
@available(iOS 14, *)
public struct PODefaultSavedPaymentMethodStyle: POSavedPaymentMethodStyle {

    /// Description text style.
    public let description: POTextStyle

    /// Delete button style.
    public let deleteButton: any ButtonStyle

    public init(description: POTextStyle, deleteButton: any ButtonStyle) {
        self.description = description
        self.deleteButton = deleteButton
    }

    // MARK: - POSavedPaymentMethodStyle

    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: POSpacing.small) {
            configuration.icon
                .frame(width: 24, height: 24)
            configuration.description
                .textStyle(description)
                .lineLimit(1)
            Spacer()
            configuration.deleteButton
                .buttonStyle(POAnyButtonStyle(erasing: deleteButton))
        }
        .padding(POSpacing.large)
    }
}
