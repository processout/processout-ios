//
//  PONativeAlternativePaymentConfirmationProgressViewStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.06.2025.
//

import SwiftUI

/// A type that specifies the appearance and interaction of confirmation progress view styles a view hierarchy.
@MainActor
@available(iOS 14.0, *)
public protocol PONativeAlternativePaymentConfirmationProgressViewStyle { // swiftlint:disable:this type_name

    /// A view representing the appearance and interaction of confirmation progress view.
    associatedtype Body: View

    /// Returns the appearance and interaction content for a confirmation progress view.
    @ViewBuilder func makeBody(configuration: Configuration) -> Self.Body

    /// The properties of a view.
    typealias Configuration = PONativeAlternativePaymentConfirmationProgressViewStyleConfiguration
}
