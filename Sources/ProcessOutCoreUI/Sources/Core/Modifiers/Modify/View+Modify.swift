//
//  View+Extensions.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 04.09.2023.
//

import SwiftUI

@_spi(PO)
extension View {

    @ViewBuilder
    public func modify(when condition: Bool, @ViewBuilder _ transform: (Self) -> some View) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    public func modify(@ViewBuilder _ transform: (Self) -> some View) -> some View {
        transform(self)
    }
}
