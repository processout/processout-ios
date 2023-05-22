//
//  PONativeAlternativePaymentMethodButtonsStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.05.2023.
//

import UIKit

/// Native alternative payment method buttons style.
public struct PONativeAlternativePaymentMethodButtonsStyle {

    /// The axis along which the buttons lay out.
    public let axis: NSLayoutConstraint.Axis

    /// Style for primary button.
    public let primary: POButtonStyle

    /// Style for secondary button.
    public let secondary: POButtonStyle

    /// Container separator color.
    public let separatorColor: UIColor

    /// Container background color.
    public let backgroundColor: UIColor

    /// Creates style instance.
    public init(
        axis: NSLayoutConstraint.Axis? = nil,
        primary: POButtonStyle? = nil,
        secondary: POButtonStyle? = nil,
        separatorColor: UIColor? = nil,
        backgroundColor: UIColor? = nil
    ) {
        self.axis = axis ?? .horizontal
        self.primary = primary ?? .primary
        self.secondary = secondary ?? .secondary
        self.separatorColor = separatorColor ?? Asset.Colors.New.Border.subtle.color
        self.backgroundColor = backgroundColor ?? Asset.Colors.New.Surface.level1.color
    }
}
