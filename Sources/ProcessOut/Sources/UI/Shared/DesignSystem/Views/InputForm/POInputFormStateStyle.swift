//
//  POInputFormStateStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 28.11.2022.
//

public struct POInputFormStateStyle {

    /// Title style.
    public let title: POTextStyle

    /// Input field style.
    public let field: POTextFieldStyle

    /// Description style.
    public let description: POTextStyle

    public init(title: POTextStyle, field: POTextFieldStyle, description: POTextStyle) {
        self.title = title
        self.field = field
        self.description = description
    }
}
