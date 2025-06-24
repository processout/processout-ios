//
//  Color+Input.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.01.2025.
//

import SwiftUI

// swiftlint:disable nesting

extension Color {

    @_spi(PO)
    public enum Input {

        public enum Text {

            /// The "Input/Text/Default" color.
            public static let `default` = Color(
                light: UIColor(0x000000), dark: UIColor(0xFFFFFF)
            )

            /// The "Input/Text/Error" color.
            public static let error = Color(
                light: UIColor(0xBE011B), dark: UIColor(0xFF7D6C)
            )
        }

        /// The "Input/Background" color namespace.
        enum Background {

            /// The "Input/Background/Default" color.
            static let `default` = Color(
                light: UIColor(0xFFFFFF), dark: UIColor(0x26292F)
            )
        }

        /// The "Input/Border" color namespace.
        enum Border {

            /// The "Input/Border/Default" color.
            static let `default` = Color(
                light: UIColor(0x121314, alpha: 0.12), dark: UIColor(0xF6F8FB, alpha: 0.16)
            )

            /// The "Input/Border/Focused" color.
            static let focused = Color(
                light: UIColor(0x000000), dark: UIColor(0xFFFFFF)
            )

            /// The "Input/Border/Error" color.
            static let error = Color(
                light: UIColor(0xBE011B), dark: UIColor(0xFF8888)
            )
        }

        /// The "Input/Label" color namespace.
        enum Label {

            /// The "Input/Placeholder/Default color.
            static let `default` = Color(
                light: UIColor(0x707378), dark: UIColor(0xA7A9AF)
            )

            /// The "Input/Placeholder/Error" color.
            static let error = Color(
                light: UIColor(0xBE011B), dark: UIColor(0xFF8888)
            )
        }

        /// The "Input/Tint" color.
        static let tint = Color(
            light: UIColor(0x000000), dark: UIColor(0xFFFFFF)
        )
    }
}

// swiftlint:enable nesting
