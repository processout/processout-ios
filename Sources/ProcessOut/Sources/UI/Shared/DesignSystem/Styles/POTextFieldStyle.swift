//
//  POTextFieldStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.11.2022.
//

import UIKit

public struct POTextFieldStyle {

    /// Button's background color.
    public let text: POTextStyle

    /// Button's background color.
    public let backgroundColor: UIColor

    /// Corner radius.
    public let cornerRadius: CGFloat

    /// Border color.
    public let borderColor: UIColor?

    /// Border width.
    public let borderWidth: CGFloat

    /// Carret color.
    public let carretColor: UIColor

    public init(
        text: POTextStyle,
        backgroundColor: UIColor,
        cornerRadius: CGFloat,
        borderColor: UIColor?,
        borderWidth: CGFloat,
        carretColor: UIColor
    ) {
        self.text = text
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.carretColor = carretColor
    }
}
