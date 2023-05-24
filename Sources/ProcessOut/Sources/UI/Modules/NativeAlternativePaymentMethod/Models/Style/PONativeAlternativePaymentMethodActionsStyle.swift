//
//  PONativeAlternativePaymentMethodActionsStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.05.2023.
//

import UIKit

/// Native alternative payment method buttons style.
public struct PONativeAlternativePaymentMethodActionsStyle {

    /// Style for primary button.
    public let primary: POButtonStyle

    /// Style for secondary button.
    public let secondary: POButtonStyle

    /// The axis along which the buttons lay out.
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
        self.axis = axis ?? .horizontal
        self.separatorColor = separatorColor ?? Asset.Colors.Border.subtle.color
        self.backgroundColor = backgroundColor ?? Asset.Colors.Surface.level1.color
    }
}
