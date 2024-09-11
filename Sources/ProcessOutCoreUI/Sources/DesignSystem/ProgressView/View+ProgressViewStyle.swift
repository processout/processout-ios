//
//  View+ProgressViewStyle.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 07.11.2023.
//

import SwiftUI

extension View {

    /// Sets the style for progress views in this view. This method should be used when
    /// specific style type is unknown and there is no possibility to use generic.
    @available(iOS 14, *)
    @_spi(PO)
    public func poProgressViewStyle(_ style: any ProgressViewStyle) -> some View {
        AnyView(self.progressViewStyle(style))
    }
}
