//
//  Markdown+Style.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 28.09.2023.
//

import SwiftUI

extension POMarkdown {

    /// Applies given `style` to text.
    @_spi(PO) public func textStyle(_ style: POTextStyle) -> some View {
        textStyle(style, addPadding: false)
    }
}
