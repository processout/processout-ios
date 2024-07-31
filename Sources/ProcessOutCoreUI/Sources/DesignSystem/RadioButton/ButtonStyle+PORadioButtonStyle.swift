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
                    backgroundColor: .clear,
                    border: .regular(color: Color(poResource: .Input.Border.default)),
                    innerCircleColor: Color(poResource: .Input.Border.default).opacity(0),
                    innerCircleRadius: 0
                ),
                value: valueStyle
            ),
            selected: .init(
                knob: .init(
                    backgroundColor: .clear,
                    border: .regular(color: Color(poResource: .Button.Primary.Background.default)),
                    innerCircleColor: Color(poResource: .Button.Primary.Background.default),
                    innerCircleRadius: 5
                ),
                value: valueStyle
            ),
            highlighted: .init(
                knob: .init(
                    backgroundColor: .clear,
                    border: .regular(color: Color(poResource: .Input.Border.hover)),
                    innerCircleColor: Color(poResource: .Input.Border.hover).opacity(0),
                    innerCircleRadius: 0
                ),
                value: valueStyle
            ),
            error: .init(
                knob: .init(
                    backgroundColor: .clear,
                    border: .regular(color: Color(poResource: .Text.error)),
                    innerCircleColor: Color(poResource: .Text.error).opacity(0),
                    innerCircleRadius: 0
                ),
                value: valueStyle
            ),
            disabled: .init(
                knob: .init(
                    backgroundColor: .clear,
                    border: .regular(color: Color(poResource: .Input.Border.disabled)),
                    innerCircleColor: Color(poResource: .Input.Border.disabled).opacity(0),
                    innerCircleRadius: 0
                ),
                value: valueStyle
            )
        )
    }

    // MARK: - Private Properties

    private static var valueStyle: POTextStyle {
        POTextStyle(color: Color(poResource: .Text.primary), typography: .button)
    }
}
