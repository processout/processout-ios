//
//  View+AnyGroupBoxStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.06.2025.
//

import SwiftUI

extension View {

    @available(iOS 14.0, *)
    @_spi(PO)
    public func poGroupBoxStyle(_ style: any GroupBoxStyle) -> some View {
        AnyView(groupBoxStyle(style))
    }
}
