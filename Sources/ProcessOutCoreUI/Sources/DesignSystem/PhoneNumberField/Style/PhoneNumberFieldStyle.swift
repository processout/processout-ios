//
//  PhoneNumberFieldStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.05.2025.
//

import SwiftUI

/// A type that specifies the appearance and interaction of all phone number fields within a view hierarchy.
@_spi(PO)
@MainActor
@preconcurrency
public protocol POPhoneNumberFieldStyle: Sendable {

    /// A view representing the appearance and interaction of a `POPhoneNumberField`.
    associatedtype Body: View

    /// Returns the appearance and interaction content for a `POPhoneNumberField`.
    ///
    /// - Parameter configuration : The properties of the field.
    @ViewBuilder func makeBody(configuration: Configuration) -> Self.Body

    /// The properties of a field.
    typealias Configuration = POPhoneNumberFieldStyleConfiguration
}
