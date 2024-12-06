//
//  View+Mask.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.12.2024.
//

import SwiftUI

extension View {

    @_spi(PO)
    public func invertMask<Mask: View>(alignment: Alignment = .center, @ViewBuilder _ mask: () -> Mask) -> some View {
        self.mask(Rectangle().overlay(mask().blendMode(.destinationOut), alignment: alignment))
    }
}
