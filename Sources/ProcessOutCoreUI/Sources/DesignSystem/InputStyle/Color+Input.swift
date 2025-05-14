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

        @_spi(PO)
        public enum Label {

            /// The "Input/Label/Default" color.
            public static let `default` = Color(
                light: UIColor(0x000000), dark: UIColor(0xFFFFFF)
            )

            /// The "Input/Label/Error" color.
            public static let error = Color(
                light: UIColor(0xBE011B), dark: UIColor(0xFF8888)
            )
        }

        /// The "Input/Background" color namespace.
        enum Background {

            /// The "Input/Background/Default" color.
            static let `default` = Color(
                light: UIColor(0x121314, alpha: 0.06), dark: UIColor(0xF6F8FB, alpha: 0.08)
            )

            /// The "Input/Background/Error" color.
            static let error = Color(
                light: UIColor(0xFCEEED), dark: UIColor(0x3D0D04)
            )

            /// The "Input/Background/Focused" color.
            static let focused = Color(
                light: UIColor(0xFFFFFF), dark: UIColor(0xF6F8FB, alpha: 0.08)
            )

            /// The "Input/Background/ErrorFocused" color.
            static let errorFocused = Color(
                // fixme(andrii-vysotskyi): use proper color when animation is fixed
                light: UIColor(0xFCEEED), dark: UIColor(0x3D0D04)
            )
        }

        /// The "Input/Border" color namespace.
        enum Border {

            /// The "Input/Border/Default" color.
            static let `default` = Color(
                light: .clear, dark: UIColor(0xF6F8FB, alpha: 0.16)
            )

            /// The "Input/Border/Error" color.
            static let error = Color(
                light: UIColor(0xBE011B), dark: UIColor(0xFF8888)
            )

            /// The "Input/Border/Focused" color.
            static let focused = Color(
                light: UIColor(0x000000), dark: UIColor(0xFFFFFF)
            )

            /// The "Input/Border/ErrorFocused" color.
            static let errorFocused = Color(
                light: UIColor(0xBE011B), dark: UIColor(0xFF8888)
            )
        }

        /// The "Input/Placeholder" color namespace.
        enum Placeholder {

            /// The "Input/Placeholder/Default color.
            static let `default` = Color(
                light: UIColor(0x707378), dark: UIColor(0xA7A9AF)
            )

            /// The "Input/Placeholder/Error" color.
            static let error = Color(
                light: UIColor(0x707378), dark: UIColor(0xA7A9AF)
            )

            /// The "Input/Placeholder/Focused" color.
            static let focused = Color(
                light: UIColor(0x707378), dark: UIColor(0xA7A9AF)
            )

            /// The "Input/Placeholder/ErrorFocused color.
            static let errorFocused = Color(
                light: UIColor(0x707378), dark: UIColor(0xA7A9AF)
            )
        }

        /// The "Input/Text" color namespace.
        enum Text {

            /// The "Input/Text/Default" color.
            static let `default` = Color(
                light: UIColor(0x000000), dark: UIColor(0xFFFFFF)
            )

            /// The "Input/Text/Error" color.
            static let error = Color(
                light: UIColor(0x000000), dark: UIColor(0xFFFFFF)
            )

            /// The "Input/Text/Focused" color.
            static let focused = Color(
                light: UIColor(0x000000), dark: UIColor(0xFFFFFF)
            )

            /// The "Input/Text/ErrorFocused" color.
            static let errorFocused = Color(
                light: UIColor(0x000000), dark: UIColor(0xFFFFFF)
            )
        }

        /// The "Input/Tint" color.
        static let tint = Color(
            light: UIColor(0x000000), dark: UIColor(0xFFFFFF)
        )
    }
}

// swiftlint:enable nesting
