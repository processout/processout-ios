//
//  Color+Button.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.01.2025.
//

import SwiftUI

// swiftlint:disable nesting

extension Color {

    /// The "Button" color namespace.
    enum Button {

        /// The "Button/Primary" color namespace.
        enum Primary {

            /// The "Button/Primary/Background" color namespace.
            enum Background {

                /// The "Button/Primary/Background/Default" color.
                static let `default` = Color(
                    light: UIColor(0x000000), dark: UIColor(0xFFFFFF)
                )

                /// The "Button/Primary/Background/Disabled" color.
                static let disabled = Color(
                    light: UIColor(0x121314, alpha: 0.04), dark: UIColor(0x2E3137)
                )

                /// The "Button/Primary/Background/Pressed" color.
                static let pressed = Color(
                    light: UIColor(0x26292F), dark: UIColor(0x585A5F)
                )
            }

            /// The "Button/Primary/Title" color namespace.
            enum Title {

                /// The "Button/Primary/Title/Default" color.
                static let `default` = Color(
                    light: UIColor(0xFFFFFF), dark: UIColor(0x000000)
                )

                /// The "Button/Primary/Title/Disabled" color.
                static let disabled = Color(
                    light: UIColor(0xC0C3C8), dark: UIColor(0x707378)
                )

                /// The "Button/Primary/Title/Pressed" color.
                static let pressed = Color(
                    light: UIColor(0xFFFFFF), dark: UIColor(0xFCFCFC)
                )
            }
        }

        /// The "Button/Secondary" color namespace.
        enum Secondary {

            /// The "Button/Secondary/Background" color namespace.
            enum Background {

                /// The "Button/Secondary/Background/Default" color.
                static let `default` = Color(
                    light: UIColor(0x121314, alpha: 0.06), dark: UIColor(0xF6F8FB, alpha: 0.08)
                )

                /// The "Button/Secondary/Background/Disabled" color.
                static let disabled = Color(
                    light: UIColor(0x121314, alpha: 0.04), dark: UIColor(0x2E3137)
                )

                /// The "Button/Secondary/Background/Pressed" color.
                static let pressed = Color(
                    light: UIColor(0x212222, alpha: 0.16), dark: UIColor(0xF6F8FB, alpha: 0.06)
                )
            }

            /// The "Button/Secondary/Title" color namespace.
            enum Title {

                /// The "Button/Secondary/Title/Default" color.
                static let `default` = Color(
                    light: UIColor(0x000000), dark: UIColor(0xFCFCFC)
                )

                /// The "Button/Secondary/Title/Disabled" color.
                static let disabled = Color(
                    light: UIColor(0xC0C3C8), dark: UIColor(0x707378)
                )

                /// The "Button/Secondary/Title/Pressed" color.
                static let pressed = Color(
                    light: UIColor(0x000000), dark: UIColor(0xFCFCFC)
                )
            }
        }

        /// The "Button/Ghost" color namespace.
        enum Ghost {

            /// The "Button/Ghost/Background" color namespace.
            enum Background {

                /// The "Button/Ghost/Background/Default" color.
                static let `default` = Color.clear

                /// The "Button/Ghost/Background/Disabled" color.
                static let disabled = Color(
                    light: UIColor(0x121314, alpha: 0.04), dark: UIColor(0x2E3137)
                )

                /// The "Button/Ghost/Background/Pressed" color.
                static let pressed = Color(
                    light: UIColor(0x121314, alpha: 0.12), dark: UIColor(0xF6F8FB, alpha: 0.12)
                )

                /// The "Button/Ghost/Background/Selected" color.
                static let selected = Color(
                    light: UIColor(0x121314, alpha: 0.12), dark: UIColor(0xF6F8FB, alpha: 0.12)
                )
            }

            /// The "Button/Ghost/Title" color namespace.
            enum Title {

                /// The "Button/Ghost/Title/Default" color.
                static let `default` = Color(
                    light: UIColor(0x585A5F), dark: UIColor(0xC0C3C8)
                )

                /// The "Button/Ghost/Title/Disabled" color.
                static let disabled = Color(
                    light: UIColor(0xC0C3C8), dark: UIColor(0x707378)
                )

                /// The "Button/Ghost/Title/Pressed" color.
                static let pressed = Color(
                    light: UIColor(0x000000), dark: UIColor(0xFCFCFC)
                )

                /// The "Button/Ghost/Title/Selected" color.
                static let selected = Color(
                    light: UIColor(0x000000), dark: UIColor(0xFCFCFC)
                )
            }
        }
    }
}

// swiftlint:enable nesting
