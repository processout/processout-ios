//
//  DynamicCheckoutSectionSeparatorView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 21.03.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

struct DynamicCheckoutSectionSeparatorView: View {

    var body: some View {
        let dividerThickness: CGFloat = 1
        HStack(spacing: POSpacing.small) {
            Rectangle()
                .fill(Color.black)
                .frame(maxWidth: .infinity, maxHeight: dividerThickness)
            // todo(andrii-vysotskyi): replace with localized string
            Text("or")
            Rectangle()
                .fill(Color.black)
                .frame(maxWidth: .infinity, maxHeight: dividerThickness)
        }
    }

    // MARK: - Private Properties

    @Environment(\.dynamicCheckoutStyle)
    private var style
}
