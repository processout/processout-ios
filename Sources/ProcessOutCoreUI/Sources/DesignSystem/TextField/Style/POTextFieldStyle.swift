//
//  POTextFieldStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 29.01.2025.
//

import SwiftUI

@_spi(PO)
@MainActor
public protocol POTextFieldStyle: Sendable {

    /// A view representing the appearance and interaction of a `POTextField`.
    associatedtype Body: View

    /// Returns the appearance and interaction content for a `POTextField`.
    ///
    /// - Parameter configuration : The properties of the text field.
    @ViewBuilder func makeBody(configuration: Configuration) -> Self.Body

    /// The properties of a text field.
    typealias Configuration = POTextFieldStyleConfiguration
}
