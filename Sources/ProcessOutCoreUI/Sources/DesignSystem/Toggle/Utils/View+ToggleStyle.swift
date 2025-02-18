//
//  View+ToggleStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 30.07.2024.
//

import SwiftUI

extension View {

    /// Sets the style for toggle views in this view. This method should be used when
    /// specific style type is unknown.
    @_spi(PO)
    public func poToggleStyle(_ style: any ToggleStyle) -> some View {
        AnyView(self.toggleStyle(style))
    }
}
