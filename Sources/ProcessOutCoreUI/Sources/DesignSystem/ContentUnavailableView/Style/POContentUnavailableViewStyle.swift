//
//  POContentUnavailableViewStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.01.2025.
//

import SwiftUI

/// A type that specifies the appearance and interaction of all content unavailable views
/// within a view hierarchy.
@MainActor
public protocol POContentUnavailableViewStyle {

    /// A view representing the appearance and interaction of a `POContentUnavailableViewStyle`.
    associatedtype Body: View

    /// Returns the appearance and interaction content for a `POContentUnavailableViewStyle`.
    ///
    /// - Parameter configuration : The properties of the view.
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Self.Body

    /// The properties of a content unavailable view.
    typealias Configuration = POContentUnavailableViewStyleConfiguration
}
