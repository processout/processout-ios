//
//  POPickerStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.04.2023.
//

public struct POPickerStyle {

    /// Style for normal state.
    public let normal: POPickerStateStyle

    /// Style for highlighted state.
    public let highlighted: POPickerStateStyle

    public init(normal: POPickerStateStyle, highlighted: POPickerStateStyle) {
        self.normal = normal
        self.highlighted = highlighted
    }
}
