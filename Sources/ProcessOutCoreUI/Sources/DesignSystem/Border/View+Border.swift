//
//  View+Border.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 31.08.2023.
//

import SwiftUI

extension View {

    /// Applies border of a given style to view.
    public func border(style: POBorderStyle) -> some View {
        let borderRectangle = RoundedRectangle(cornerRadius: style.radius)
            .stroke(Color(style.color), lineWidth: style.width)
        return self.overlay(borderRectangle).cornerRadius(style.radius)
    }
}
