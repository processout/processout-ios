//
//  View+Border.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 31.08.2023.
//

import SwiftUI

extension View {

    /// Applies border of a given style to view.
    func border(style: POBorderStyle) -> some View {
        let borderRectangle = RoundedRectangle(cornerRadius: style.radius)
            .stroke(style.color, lineWidth: style.width)
        return self.overlay(borderRectangle).clipShape(RoundedRectangle(cornerRadius: style.radius))
    }
}
