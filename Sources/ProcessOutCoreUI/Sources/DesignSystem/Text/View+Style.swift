//
//  Text+Style.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 05.09.2023.
//

import SwiftUI

extension View {

    /// - Parameters:
    ///   - style: The text style.
    ///   - maximumFontSize: The maximum point size allowed for the font. Use this value to constrain the font to
    ///   the specified size when your interface cannot accommodate text that is any larger.
    ///   - textStyle: Constants that describe the preferred styles for fonts.
    public func textStyle(
        _ style: POTextStyle,
        maximumFontSize maxSize: CGFloat = .greatestFiniteMagnitude,
        relativeTo textStyle: UIFont.TextStyle = .body
    ) -> some View {
        let color = Color(style.color)
        return self.typography(style.typography, maximumFontSize: maxSize, relativeTo: textStyle).foregroundColor(color)
    }
}
