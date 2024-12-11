//
//  View+Shadow.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 31.08.2023.
//

import SwiftUI

extension View {

    /// Applies shadow of a given style to a view.
    @_spi(PO)
    public func shadow(style: POShadowStyle) -> some View {
        self.shadow(color: style.color, radius: style.radius, x: style.offset.width, y: style.offset.height)
    }
}
