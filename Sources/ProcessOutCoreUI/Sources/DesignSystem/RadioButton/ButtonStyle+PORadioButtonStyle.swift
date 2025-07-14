//
//  ButtonStyle+PORadioButtonStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 20.10.2023.
//

import SwiftUI

extension ButtonStyle where Self == PORadioButtonStyle {

    /// Radio button style with default appearance.
    @_disfavoredOverload
    public static var radio: PORadioButtonStyle {
        PORadioButtonStyle(
            normal: .init(
                knob: .init(
                    backgroundColor: .Radio.Knob.Background.default,
                    border: .radioButton(color: .Radio.Knob.Border.default),
                    innerCircleColor: .Radio.Knob.Value.default,
                    innerCircleRadius: 4
                ),
                value: .init(
                    color: .Radio.Text.default,
                    typography: .Text.s14(weight: .medium)
                ),
                backgroundColor: .Radio.Background.default
            ),
            selected: .init(
                knob: .init(
                    backgroundColor: .Radio.Knob.Background.selected,
                    border: .radioButton(color: .Radio.Knob.Border.selected),
                    innerCircleColor: .Radio.Knob.Value.selected,
                    innerCircleRadius: 4
                ),
                value: .init(
                    color: .Radio.Text.selected,
                    typography: .Text.s14(weight: .medium)
                ),
                backgroundColor: .Radio.Background.selected
            ),
            highlighted: .init(
                knob: .init(
                    backgroundColor: .Radio.Knob.Background.pressed,
                    border: .radioButton(color: .Radio.Knob.Border.pressed),
                    innerCircleColor: .Radio.Knob.Value.pressed,
                    innerCircleRadius: 4
                ),
                value: .init(
                    color: .Radio.Text.pressed,
                    typography: .Text.s14(weight: .medium)
                ),
                backgroundColor: .Radio.Background.pressed
            ),
            error: .init(
                knob: .init(
                    backgroundColor: .Radio.Knob.Background.error,
                    border: .radioButton(color: .Radio.Knob.Border.error),
                    innerCircleColor: .Radio.Knob.Value.error,
                    innerCircleRadius: 4
                ),
                value: .init(
                    color: .Radio.Text.error,
                    typography: .Text.s14(weight: .medium)
                ),
                backgroundColor: .Radio.Background.error
            ),
            disabled: .init(
                knob: .init(
                    backgroundColor: .Radio.Knob.Background.disabled,
                    border: .radioButton(color: .Radio.Knob.Border.disabled),
                    innerCircleColor: .Radio.Knob.Value.disabled,
                    innerCircleRadius: 3
                ),
                value: .init(
                    color: .Radio.Text.disabled,
                    typography: .Text.s14(weight: .medium)
                ),
                backgroundColor: .Radio.Background.disabled
            )
        )
    }
}
