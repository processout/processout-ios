//
//  Color+Symbols.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.01.2025.
//

import SwiftUI

extension Color {

    @_spi(PO)
    public enum Surface {

        /// Surface/Primary color.
        public static let primary = Color(light: UIColor(0xFCFCFC), dark: UIColor(0x1D2026))
    }

    @_spi(PO)
    public enum Text {

        /// Text/Primary color.
        public static let primary = Color(light: UIColor(0x000000), dark: UIColor(0xFFFFFF))

        /// Text/Secondary color.
        public static let secondary = Color(light: UIColor(0x585A5F), dark: UIColor(0xC0C3C8))

        /// Text/Inverse color.
        public static let inverse = Color(light: UIColor(0xFFFFFF), dark: UIColor(0x000000))
    }
}
