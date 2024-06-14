//
//  EdgeInsets.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 05.06.2024.
//

import SwiftUI

extension EdgeInsets {

    @_spi(PO)
    public init(horizontal: CGFloat, vertical: CGFloat) {
        self = .init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }
}
