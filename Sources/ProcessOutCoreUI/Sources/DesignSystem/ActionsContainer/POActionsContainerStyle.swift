//
//  POActionsContainerStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 19.10.2023.
//

import SwiftUI

/// Actions container style.
public struct POActionsContainerStyle {

    /// Style for primary button.
    public let primary: any ButtonStyle

    /// Style for secondary button.
    public let secondary: any ButtonStyle

    /// The axis along which the buttons lay out. By default actions are positioned vertically.
    public let axis: Axis

    /// Container separator color.
    public let separatorColor: Color

    /// Container background color.
    public let backgroundColor: Color

    /// Creates style instance.
    public init(
        primary: some ButtonStyle,
        secondary: some ButtonStyle,
        axis: Axis = .vertical,
        separatorColor: Color = .clear,
        backgroundColor: Color = .clear
    ) {
        self.primary = primary
        self.secondary = secondary
        self.axis = axis
        self.separatorColor = separatorColor
        self.backgroundColor = backgroundColor
    }
}

extension POActionsContainerStyle {

    /// Default actions container style.
    @available(iOS 14, *)
    public static var `default`: POActionsContainerStyle {
        POActionsContainerStyle(
            primary: .primary,
            secondary: .secondary,
            separatorColor: Color(.Border.subtle),
            backgroundColor: Color(.Surface.level1)
        )
    }
}
