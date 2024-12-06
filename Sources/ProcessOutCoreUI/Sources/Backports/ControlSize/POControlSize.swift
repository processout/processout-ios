//
//  POControlSize.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.12.2024.
//

/// The size classes, like regular or small, that you can apply to controls
/// within a view.
public enum POControlSize: CaseIterable, Hashable, Sendable {

    /// A control version that is proportionally smaller size for space-constrained views.
    case small

    /// A control version that is the default size.
    case regular
}
