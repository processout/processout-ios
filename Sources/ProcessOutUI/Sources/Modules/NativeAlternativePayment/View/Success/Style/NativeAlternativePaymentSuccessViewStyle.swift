//
//  NativeAlternativePaymentSuccessViewStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.06.2025.
//

import SwiftUI

/// A type that specifies the appearance and interaction of success view styles a view hierarchy.
@MainActor
public protocol PONativeAlternativePaymentSuccessViewStyle {

    /// A view representing the appearance payment success view.
    associatedtype Body: View

    /// Returns the appearance and interaction content for a payment success view.
    @ViewBuilder func makeBody(configuration: Configuration) -> Self.Body

    /// The properties of a view.
    typealias Configuration = PONativeAlternativePaymentSuccessViewStyleConfiguration
}
