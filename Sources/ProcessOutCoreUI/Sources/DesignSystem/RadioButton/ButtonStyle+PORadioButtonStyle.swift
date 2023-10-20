//
//  ButtonStyle+PORadioButtonStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 20.10.2023.
//

import SwiftUI

extension ButtonStyle where Self == PORadioButtonStyle {

    @_spi(PO) public static var radio: PORadioButtonStyle {
        PORadioButtonStyle(
            normal: .init(
                knob: .init(
                    backgroundColor: .clear,
                    border: .regular(color: UIColor(resource: .Border.default)),
                    innerCircleColor: .clear,
                    innerCircleRadius: 0
                ),
                value: valueStyle
            ),
            selected: .init(
                knob: .init(
                    backgroundColor: .clear,
                    border: .regular(color: UIColor(resource: .Action.Primary.default)),
                    innerCircleColor: UIColor(resource: .Action.Primary.default),
                    innerCircleRadius: 4
                ),
                value: valueStyle
            ),
            highlighted: .init(
                knob: .init(
                    backgroundColor: .clear,
                    border: .regular(color: UIColor(resource: .Text.muted)),
                    innerCircleColor: .clear,
                    innerCircleRadius: 0
                ),
                value: valueStyle
            ),
            error: .init(
                knob: .init(
                    backgroundColor: .clear,
                    border: .regular(color: UIColor(resource: .Text.error)),
                    innerCircleColor: .clear,
                    innerCircleRadius: 0
                ),
                value: valueStyle
            )
        )
    }

    // MARK: - Private Properties

    private static var valueStyle: POTextStyle {
        POTextStyle(color: UIColor(resource: .Text.primary), typography: .Fixed.label)
    }
}
