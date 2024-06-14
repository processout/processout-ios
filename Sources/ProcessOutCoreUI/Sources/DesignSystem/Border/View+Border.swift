//
//  View+Border.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 31.08.2023.
//

import SwiftUI

extension View {

    /// Applies border of a given style to view.
    @_spi(PO)
    public func border(style: POBorderStyle) -> some View {
        border(RoundedRectangle(cornerRadius: style.radius), style: style)
    }

    // MARK: - Private Methods

    /// Applies border shape with specified style to view.
    private func border(_ content: some InsettableShape, style: POBorderStyle) -> some View {
        let borderShape = content.strokeBorder(style.color, lineWidth: style.width)
        return self.overlay(borderShape).clipShape(content)
    }
}
