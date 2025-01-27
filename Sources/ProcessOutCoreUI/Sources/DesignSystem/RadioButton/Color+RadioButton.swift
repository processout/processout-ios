//
//  Color+RadioButton.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.01.2025.
//

import SwiftUI

extension Color {

    /// The "Radio" color namespace.
    enum Radio {

        /// The "Radio/Knob" color namespace.
        enum Knob {

            /// The "Radio/Knob/Background" color namespace.
            enum Background {

                /// The "Radio/Knob/Background/Default" color.
                static let `default` = Color(
                    light: UIColor(0xFFFFFF), dark: UIColor(0x121314, alpha: 0.2)
                )

                /// The "Radio/Knob/Background/Disabled" color.
                static let disabled = Color(
                    light: UIColor(0xF0F2F4), dark: UIColor(0x2E3137)
                )

                /// The "Radio/Knob/Background/Error" color.
                static let error = Color(
                    light: UIColor(0xFDE3DE), dark: UIColor(0x3D0D04)
                )

                /// The "Radio/Knob/Background/Pressed" color.
                static let pressed = Color(
                    light: UIColor(0xFFFFFF), dark: UIColor(0x121314, alpha: 0.2)
                )

                /// The "Radio/Knob/Background/Selected" color.
                static let selected = Color(
                    light: UIColor(0x000000), dark: UIColor(0xFFFFFF)
                )

                /// The "Radio/Knob/Background/SelectedPressed" color.
                static let selectedPressed = Color(
                    light: UIColor(0x000000), dark: UIColor(0xFFFFFF)
                )
            }

            /// The "Radio/Knob/Border" color namespace.
            enum Border {

                /// The "Radio/Knob/Border/Default" color.
                static let `default` = Color(
                    light: UIColor(0xC0C3C8), dark: UIColor(0xF6F8FB, alpha: 0.24)
                )

                /// The "Radio/Knob/Border/Disabled" color.
                static let disabled = Color(
                    light: UIColor(0xC0C3C8), dark: UIColor(0x707378)
                )

                /// The "Radio/Knob/Border/Error" color.
                static let error = Color(
                    light: UIColor(0xF03030), dark: UIColor(0xFF7D6C)
                )

                /// The "Radio/Knob/Border/Pressed" color.
                static let pressed = Color(
                    light: UIColor(0xC0C3C8), dark: UIColor(0xF6F8FB, alpha: 0.24)
                )

                /// The "Radio/Knob/Border/Selected" color.
                static let selected = Color.clear

                /// The "Radio/Knob/Border/SelectedPressed" color.
                static let selectedPressed = Color.clear
            }

            /// The "Radio/Knob/Value" color namespace.
            enum Value {

                /// The "Radio/Knob/Value/Default" color.
                static let `default` = Color(
                    light: UIColor(0xC0C3C8), dark: UIColor(0xF6F8FB, alpha: 0.24)
                )

                /// The "Radio/Knob/Value/Disabled" color.
                static let disabled = Color(
                    light: UIColor(0xC0C3C8), dark: UIColor(0x707378)
                )

                /// The "Radio/Knob/Value/Error" color.
                static let error = Color(
                    light: UIColor(0xF03030), dark: UIColor(0xFF7D6C)
                )

                /// The "Radio/Knob/Value/Pressed" color.
                static let pressed = Color(
                    light: UIColor(0xC0C3C8), dark: UIColor(0xF6F8FB, alpha: 0.24)
                )

                /// The "Radio/Knob/Value/Selected" color.
                static let selected = Color(
                    light: UIColor(0xFFFFFF), dark: UIColor(0x000000)
                )

                /// The "Radio/Knob/Value/SelectedPressed" color.
                static let selectedPressed = Color(
                    light: UIColor(0xFFFFFF), dark: UIColor(0x000000)
                )
            }
        }

        /// The "Radio/Text" color namespace.
        enum Text {

            /// The "Radio/Text/Default" color.
            static let `default` = Color(
                light: UIColor(0x000000), dark: UIColor(0xFFFFFF)
            )

            /// The "Radio/Text/Disabled" color.
            static let disabled = Color(
                light: UIColor(0x000000), dark: UIColor(0xFFFFFF)
            )

            /// The "Radio/Text/Error" color.
            static let error = Color(
                light: UIColor(0x000000), dark: UIColor(0xFFFFFF)
            )

            /// The "Radio/Text/Pressed" color.
            static let pressed = Color(
                light: UIColor(0x000000), dark: UIColor(0xFFFFFF)
            )

            /// The "Radio/Text/Selected" color.
            static let selected = Color(
                light: UIColor(0x000000), dark: UIColor(0xFFFFFF)
            )

            /// The "Radio/Text/SelectedPressed" color.
            static let selectedPressed = Color(
                light: UIColor(0x000000), dark: UIColor(0xFFFFFF)
            )
        }

        /// The "Radio/Background" color namespace.
        enum Background {

            /// The "Radio/Background/Default" color.
            static let `default` = Color.clear

            /// The "Radio/Background/Disabled" color.
            static let disabled = Color.clear

            /// The "Radio/Background/Error" color.
            static let error = Color.clear

            /// The "Radio/Background/Pressed" color.
            static let pressed = Color(
                light: UIColor(0x121314, alpha: 0.06), dark: UIColor(0xF6F8FB, alpha: 0.06)
            )

            /// The "Radio/Background/Selected" color.
            static let selected = Color.clear

            /// The "Radio/Background/SelectedPressed" color.
            static let selectedPressed = Color(
                light: UIColor(0x121314, alpha: 0.06), dark: UIColor(0xF6F8FB, alpha: 0.06)
            )
        }
    }
}
