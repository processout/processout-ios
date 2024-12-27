//
//  PODefaultSavedPaymentMethodsStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.12.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

/// The default card scanner style.
@available(iOS 14, *)
public struct PODefaultSavedPaymentMethodsStyle: POSavedPaymentMethodsStyle {

    // MARK: - POSavedPaymentMethodsStyle

    public func makeBody(configuration: Configuration) -> some View {
        Text("Hello World")
    }
}
