//
//  POProgressViewStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 12.10.2023.
//

import SwiftUI

/// A type that applies standard interaction behavior to all progress views
/// within a view hierarchy.
@available(iOS, deprecated: 14)
public protocol POProgressViewStyle {

    /// A view representing the body of a progress view.
    associatedtype Body: View

    /// Creates a view representing the body of a progress view.
    @ViewBuilder func makeBody() -> Self.Body
}
