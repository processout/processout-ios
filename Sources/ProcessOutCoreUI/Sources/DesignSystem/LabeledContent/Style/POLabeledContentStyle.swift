//
//  POLabeledContentStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.06.2025.
//

import SwiftUI

/// The appearance and behavior of a labeled content instance.
@available(iOS 14, *)
@MainActor
@_spi(PO)
public protocol POLabeledContentStyle {

    /// A view that represents the appearance and behavior of labeled content.
    associatedtype Body: View

    /// Creates a view that represents the body of labeled content.
    @ViewBuilder
    func makeBody(configuration: Self.Configuration) -> Self.Body

    /// The properties of a labeled content instance.
    typealias Configuration = POLabeledContentStyleConfiguration
}
