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
                    color: Color(poResource: .Radio.Knob.Value.default),
                    width: 1.25,
                    backgroundColor: Color(poResource: .Radio.Knob.Background.default),
                    border: .regular(color: Color(poResource: .Radio.Knob.Border.default))
                ),
                value: POTextStyle(
                    color: Color(poResource: .Radio.Text.default),
                    typography: .Text.s14(weight: .medium)
                ),
                backgroundColor: Color(poResource: .Radio.Background.default)
            ),
            highlighted: .init(
                checkmark: .init(
                    color: Color(poResource: .Radio.Knob.Value.pressed),
                    width: 1.25,
                    backgroundColor: Color(poResource: .Radio.Knob.Background.pressed),
                    border: .regular(color: Color(poResource: .Radio.Knob.Border.pressed))
                ),
                value: POTextStyle(
                    color: Color(poResource: .Radio.Text.pressed),
                    typography: .Text.s14(weight: .medium)
                ),
                backgroundColor: Color(poResource: .Radio.Background.pressed)
            ),
            selected: .init(
                checkmark: .init(
                    color: Color(poResource: .Radio.Knob.Value.selected),
                    width: 1.25,
                    backgroundColor: Color(poResource: .Radio.Knob.Background.selected),
                    border: .regular(color: Color(poResource: .Radio.Knob.Border.selected))
                ),
                value: POTextStyle(
                    color: Color(poResource: .Radio.Text.selected),
                    typography: .Text.s14(weight: .medium)
                ),
                backgroundColor: Color(poResource: .Radio.Background.selected)
            ),
            selectedHighlighted: .init(
                checkmark: .init(
                    color: Color(poResource: .Radio.Knob.Value.selectedPressed),
                    width: 1.25,
                    backgroundColor: Color(poResource: .Radio.Knob.Background.selectedPressed),
                    border: .regular(color: Color(poResource: .Radio.Knob.Border.selectedPressed))
                ),
                value: POTextStyle(
                    color: Color(poResource: .Radio.Text.selectedPressed),
                    typography: .Text.s14(weight: .medium)
                ),
                backgroundColor: Color(poResource: .Radio.Background.selectedPressed)
            ),
            error: .init(
                checkmark: .init(
                    color: Color(poResource: .Radio.Knob.Value.error),
                    width: 1.25,
                    backgroundColor: Color(poResource: .Radio.Knob.Background.error),
                    border: .regular(color: Color(poResource: .Radio.Knob.Border.error))
                ),
                value: POTextStyle(
                    color: Color(poResource: .Radio.Text.error),
                    typography: .Text.s14(weight: .medium)
                ),
                backgroundColor: Color(poResource: .Radio.Background.error)
            ),
            disabled: .init(
                checkmark: .init(
                    color: Color(poResource: .Radio.Knob.Value.disabled),
                    width: 1.25,
                    backgroundColor: Color(poResource: .Radio.Knob.Background.disabled),
                    border: .regular(color: Color(poResource: .Radio.Knob.Border.disabled))
                ),
                value: POTextStyle(
                    color: Color(poResource: .Radio.Text.disabled),
                    typography: .Text.s14(weight: .medium)
                ),
                backgroundColor: Color(poResource: .Radio.Background.disabled)
            )
        )
    }
}
