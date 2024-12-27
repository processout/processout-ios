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

    // MARK: - POSavedPaymentMethodStyle

    public func makeBody(configuration: Configuration) -> some View {
        Text("Hello World")
    }
}
