//
//  ButtonStyle+PORadioButtonStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 20.10.2023.
//

import SwiftUI

@available(iOS 14, *)
extension ButtonStyle where Self == PORadioButtonStyle {

    /// Radio button style with default appearance.
    @_disfavoredOverload
    public static var radio: PORadioButtonStyle {
        PORadioButtonStyle(
            normal: .init(
                knob: .init(
                    backgroundColor: Color(poResource: .Radio.Knob.Background.default),
                    border: .regular(color: Color(poResource: .Radio.Knob.Border.default)),
                    innerCircleColor: Color(poResource: .Radio.Knob.Value.default),
                    innerCircleRadius: 4
                ),
                value: .init(
                    color: Color(poResource: .Radio.Text.default),
                    typography: .Text.s14(weight: .medium)
                ),
                backgroundColor: Color(poResource: .Radio.Background.default)
            ),
            selected: .init(
                knob: .init(
                    backgroundColor: Color(poResource: .Radio.Knob.Background.selected),
                    border: .regular(color: Color(poResource: .Radio.Knob.Border.selected)),
                    innerCircleColor: Color(poResource: .Radio.Knob.Value.selected),
                    innerCircleRadius: 4
                ),
                value: .init(
                    color: Color(poResource: .Radio.Text.selected),
                    typography: .Text.s14(weight: .medium)
                ),
                backgroundColor: Color(poResource: .Radio.Background.selected)
            ),
            highlighted: .init(
                knob: .init(
                    backgroundColor: Color(poResource: .Radio.Knob.Background.pressed),
                    border: .regular(color: Color(poResource: .Radio.Knob.Border.pressed)),
                    innerCircleColor: Color(poResource: .Radio.Knob.Value.pressed),
                    innerCircleRadius: 4
                ),
                value: .init(
                    color: Color(poResource: .Radio.Text.pressed),
                    typography: .Text.s14(weight: .medium)
                ),
                backgroundColor: Color(poResource: .Radio.Background.pressed)
            ),
            error: .init(
                knob: .init(
                    backgroundColor: Color(poResource: .Radio.Knob.Background.error),
                    border: .regular(color: Color(poResource: .Radio.Knob.Border.error)),
                    innerCircleColor: Color(poResource: .Radio.Knob.Value.error),
                    innerCircleRadius: 4
                ),
                value: .init(
                    color: Color(poResource: .Radio.Text.error),
                    typography: .Text.s14(weight: .medium)
                ),
                backgroundColor: Color(poResource: .Radio.Background.error)
            ),
            disabled: .init(
                knob: .init(
                    backgroundColor: Color(poResource: .Radio.Knob.Background.disabled),
                    border: .regular(color: Color(poResource: .Radio.Knob.Border.disabled)),
                    innerCircleColor: Color(poResource: .Radio.Knob.Value.disabled),
                    innerCircleRadius: 3
                ),
                value: .init(
                    color: Color(poResource: .Radio.Text.disabled),
                    typography: .Text.s14(weight: .medium)
                ),
                backgroundColor: Color(poResource: .Radio.Background.disabled)
            )
        )
    }
}
