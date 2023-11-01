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
                    border: .regular(color: Color(.Border.default)),
                    innerCircleColor: Color(.Action.Primary.default).opacity(0),
                    innerCircleRadius: 0
                ),
                value: valueStyle
            ),
            selected: .init(
                knob: .init(
                    backgroundColor: .clear,
                    border: .regular(color: Color(.Action.Primary.default)),
                    innerCircleColor: Color(.Action.Primary.default),
                    innerCircleRadius: 4
                ),
                value: valueStyle
            ),
            highlighted: .init(
                knob: .init(
                    backgroundColor: .clear,
                    border: .regular(color: Color(.Text.muted)),
                    innerCircleColor: Color(.Action.Primary.default).opacity(0),
                    innerCircleRadius: 0
                ),
                value: valueStyle
            ),
            error: .init(
                knob: .init(
                    backgroundColor: .clear,
                    border: .regular(color: Color(.Text.error)),
                    innerCircleColor: Color(.Action.Primary.default).opacity(0),
                    innerCircleRadius: 0
                ),
                value: valueStyle
            )
        )
    }

    // MARK: - Private Properties

    private static var valueStyle: POTextStyle {
        POTextStyle(color: Color(.Text.primary), typography: .Fixed.label)
    }
}
