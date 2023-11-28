//
//  CodeFieldOverlay.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 28.11.2023.
//

import SwiftUI

/// Adds border and shadow to individual code field components.
struct CodeFieldOverlay: View {

    let length: Int

    var body: some View {
        let style = isInvalid ? style.error : style.normal
        HStack(spacing: Constants.spacing) {
            ForEach(0..<length, id: \.self) { _ in
                Rectangle()
                    .fill(Color.clear)
                    .border(style: style.border)
                    .shadow(style: style.shadow)
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let spacing: CGFloat = 6
    }

    // MARK: - Private Properties

    @Environment(\.inputStyle) private var style
    @Environment(\.isControlInvalid) private var isInvalid
}
