//
//  Markdown+Style.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 28.09.2023.
//

import SwiftUI

@available(iOS 14, *)
extension POMarkdown {

    /// Applies given `style` to text.
    @_spi(PO)
    @MainActor
    public func textStyle(_ style: POTextStyle) -> some View {
        textStyle(style, addPadding: false)
    }
}
