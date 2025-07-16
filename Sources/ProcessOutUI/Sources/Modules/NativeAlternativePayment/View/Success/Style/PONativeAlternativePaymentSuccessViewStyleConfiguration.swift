//
//  PONativeAlternativePaymentSuccessViewStyleConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.06.2025.
//

import SwiftUI

/// Payment success view style configuration.
public struct PONativeAlternativePaymentSuccessViewStyleConfiguration { // swiftlint:disable:this type_name

    /// View title.
    public let title: AnyView

    /// View description.
    public let description: AnyView

    init(@ViewBuilder title: () -> some View, @ViewBuilder description: () -> some View) {
        self.title = AnyView(title())
        self.description = AnyView(description())
    }
}
