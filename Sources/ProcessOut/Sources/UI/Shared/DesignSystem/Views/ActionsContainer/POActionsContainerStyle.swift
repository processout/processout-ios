//
//  POActionsContainerStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.05.2023.
//

import UIKit

/// Actions container style.
@available(*, deprecated, message: "Use ProcessOutUI module.")
public struct POActionsContainerStyle {

    /// Style for primary button.
    public let primary: POButtonStyle

    /// Style for secondary button.
    public let secondary: POButtonStyle

    /// The axis along which the buttons lay out. By default actions are positioned vertically.
    public let axis: NSLayoutConstraint.Axis

    /// Container separator color.
    public let separatorColor: UIColor

    /// Container background color.
    public let backgroundColor: UIColor

    /// Creates style instance.
    public init(
        primary: POButtonStyle? = nil,
        secondary: POButtonStyle? = nil,
        axis: NSLayoutConstraint.Axis? = nil,
        separatorColor: UIColor? = nil,
        backgroundColor: UIColor? = nil
    ) {
        self.primary = primary ?? .primary
        self.secondary = secondary ?? .secondary
        self.axis = axis ?? .vertical
        self.separatorColor = separatorColor ?? UIColor(poResource: .Border.subtle)
        self.backgroundColor = backgroundColor ?? UIColor(poResource: .Surface.level1)
    }
}
