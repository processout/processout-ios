//
//  Color+Toast.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.01.2025.
//

import SwiftUI

extension Color {

    enum Toast {

        /// Toast/Text color.
        static let text = Color(
            light: UIColor(0x630407), dark: UIColor(0xF5D9D9)
        )

        /// Toast/Background color.
        static let background = Color(
            light: UIColor(0xFDE3DE), dark: UIColor(0x511511)
        )

        /// Toast/Border color.
        static let border = Color(
            light: UIColor(0x121314, alpha: 0.06), dark: UIColor(0xF6F8FB, alpha: 0.06)
        )
    }
}
