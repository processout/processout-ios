//
//  ToggleStyle+Checkbox.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 29.07.2024.
//

import SwiftUI

@available(iOS 14, *)
extension ToggleStyle where Self == POCheckboxToggleStyle {

    /// Checkbox toggle.
    @_disfavoredOverload
    public static var poCheckbox: POCheckboxToggleStyle {
        POCheckboxToggleStyle(
            normal: .init(
                checkmark: .init(
                    color: .Radio.Knob.Value.default,
                    width: 1.25,
                    backgroundColor: .Radio.Knob.Background.default,
                    border: .checkbox(color: .Radio.Knob.Border.default)
                ),
                value: POTextStyle(
                    color: .Radio.Text.default,
                    typography: .Text.s14(weight: .medium)
                ),
                backgroundColor: .Radio.Background.default
            ),
            highlighted: .init(
                checkmark: .init(
                    color: .Radio.Knob.Value.pressed,
                    width: 1.25,
                    backgroundColor: .Radio.Knob.Background.pressed,
                    border: .checkbox(color: .Radio.Knob.Border.pressed)
                ),
                value: POTextStyle(
                    color: .Radio.Text.pressed,
                    typography: .Text.s14(weight: .medium)
                ),
                backgroundColor: .Radio.Background.pressed
            ),
            selected: .init(
                checkmark: .init(
                    color: .Radio.Knob.Value.selected,
                    width: 1.25,
                    backgroundColor: .Radio.Knob.Background.selected,
                    border: .checkbox(color: .Radio.Knob.Border.selected)
                ),
                value: POTextStyle(
                    color: .Radio.Text.selected,
                    typography: .Text.s14(weight: .medium)
                ),
                backgroundColor: .Radio.Background.selected
            ),
            selectedHighlighted: .init(
                checkmark: .init(
                    color: .Radio.Knob.Value.selectedPressed,
                    width: 1.25,
                    backgroundColor: .Radio.Knob.Background.selectedPressed,
                    border: .checkbox(color: .Radio.Knob.Border.selectedPressed)
                ),
                value: POTextStyle(
                    color: .Radio.Text.selectedPressed,
                    typography: .Text.s14(weight: .medium)
                ),
                backgroundColor: .Radio.Background.selectedPressed
            ),
            error: .init(
                checkmark: .init(
                    color: .Radio.Knob.Value.error,
                    width: 1.25,
                    backgroundColor: .Radio.Knob.Background.error,
                    border: .checkbox(color: .Radio.Knob.Border.error)
                ),
                value: POTextStyle(
                    color: .Radio.Text.error,
                    typography: .Text.s14(weight: .medium)
                ),
                backgroundColor: .Radio.Background.error
            ),
            disabled: .init(
                checkmark: .init(
                    color: .Radio.Knob.Value.disabled,
                    width: 1.25,
                    backgroundColor: .Radio.Knob.Background.disabled,
                    border: .checkbox(color: .Radio.Knob.Border.disabled)
                ),
                value: POTextStyle(
                    color: .Radio.Text.disabled,
                    typography: .Text.s14(weight: .medium)
                ),
                backgroundColor: .Radio.Background.disabled
            )
        )
    }
}
