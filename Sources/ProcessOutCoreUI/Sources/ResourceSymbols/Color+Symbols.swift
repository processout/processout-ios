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

        /// Surface/Primary color.
        public static let successSubtle = Color(light: UIColor(0xE4F9E3), dark: UIColor(0x143225))

        /// Surface/Primary color.
        public static let elevated = Color(light: UIColor(0xFFFFFF), dark: UIColor(0x000000))
    }

    @_spi(PO)
    public enum Text {

        /// Text/Primary color.
        public static let primary = Color(light: UIColor(0x000000), dark: UIColor(0xFFFFFF))

        /// Text/Secondary color.
        public static let secondary = Color(light: UIColor(0x585A5F), dark: UIColor(0xC0C3C8))

        /// Text/Inverse color.
        public static let inverse = Color(light: UIColor(0xFFFFFF), dark: UIColor(0x000000))

        /// Text/Positive color.
        public static let positive = Color(light: UIColor(0x0A4322), dark: UIColor(0xCFF3CD))
    }

    @_spi(PO)
    public enum Icon {

        /// Icon/Error color.
        public static let error = Color(light: UIColor(0xBE011B), dark: UIColor(0xFF4E4E))
    }

    @_spi(PO)
    public enum Border {

        /// The "Border/Primary" color.
        public static let primary = Color(
            light: UIColor(0x121314, alpha: 0.06), dark: UIColor(0xF6F8FB, alpha: 0.06)
        )
    }
}
