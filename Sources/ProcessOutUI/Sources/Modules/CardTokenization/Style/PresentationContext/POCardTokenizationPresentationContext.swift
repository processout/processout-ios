//
//  POCardTokenizationPresentationContext.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 21.07.2025.
//

import SwiftUI

/// Describes how the component is placed within the UI hierarchy.
public enum POCardTokenizationPresentationContext: Sendable {

    /// The component is displayed independently with its own layout,
    /// including scroll support, padding, and other container styling.
    case standalone

    /// The component is embedded within another view.
    case inline
}
