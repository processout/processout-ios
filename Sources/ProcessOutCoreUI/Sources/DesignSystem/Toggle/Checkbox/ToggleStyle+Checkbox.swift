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
                    color: Color(poResource: .Surface.default),
                    width: checkboxWidth,
                    backgroundColor: Color(poResource: .Surface.default),
                    border: .regular(color: Color(poResource: .Input.Border.default))
                ),
                value: POTextStyle(color: Color(poResource: .Text.primary), typography: valueTypography)
            ),
            selected: .init(
                checkmark: .init(
                    color: Color(poResource: .Surface.default),
                    width: checkboxWidth,
                    backgroundColor: Color(poResource: .Button.Primary.Background.default),
                    border: .regular(color: Color(poResource: .Button.Primary.Background.default))
                ),
                value: POTextStyle(color: Color(poResource: .Text.primary), typography: valueTypography)
            ),
            error: .init(
                checkmark: .init(
                    color: Color(poResource: .Text.error),
                    width: checkboxWidth,
                    backgroundColor: Color(poResource: .Surface.default),
                    border: .regular(color: Color(poResource: .Text.error))
                ),
                value: POTextStyle(color: Color(poResource: .Text.primary), typography: valueTypography)
            ),
            disabled: .init(
                checkmark: .init(
                    color: Color(poResource: .Input.Border.disabled),
                    width: checkboxWidth,
                    backgroundColor: Color(poResource: .Input.Background.disabled),
                    border: .regular(color: Color(poResource: .Input.Border.disabled))
                ),
                value: POTextStyle(color: Color(poResource: .Text.disabled), typography: valueTypography)
            )
        )
    }

    // MARK: - Private Nested Types

    private static var valueTypography: POTypography {
        .button
    }

    private static var checkboxWidth: CGFloat {
        1.7
    }
}
