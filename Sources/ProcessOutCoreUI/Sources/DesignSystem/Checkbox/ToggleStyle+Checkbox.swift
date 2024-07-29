//
//  ToggleStyle+Checkbox.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 29.07.2024.
//

import SwiftUI

@available(iOS 14.0, *)
extension ToggleStyle where Self == POCheckboxToggleStyle {

    /// Checkbox toggle.
    @_disfavoredOverload
    public static var poCheckbox: POCheckboxToggleStyle {
        POCheckboxToggleStyle(
            normal: .init(
                checkmark: .init(
                    color: Color(.Surface.default),
                    width: checkboxWidth,
                    backgroundColor: Color(.Surface.default),
                    border: .regular(color: Color(.Input.Border.default))
                ),
                value: POTextStyle(color: Color(.Text.primary), typography: valueTypography)
            ),
            selected: .init(
                checkmark: .init(
                    color: Color(.Surface.default),
                    width: checkboxWidth,
                    backgroundColor: Color(.Button.Primary.Background.default),
                    border: .regular(color: Color(.Button.Primary.Background.default))
                ),
                value: POTextStyle(color: Color(.Text.primary), typography: valueTypography)
            ),
            error: .init(
                checkmark: .init(
                    color: Color(.Text.error),
                    width: checkboxWidth,
                    backgroundColor: Color(.Surface.default),
                    border: .regular(color: Color(.Text.error))
                ),
                value: POTextStyle(color: Color(.Text.primary), typography: valueTypography)
            ),
            disabled: .init(
                checkmark: .init(
                    color: Color(.Input.Border.disabled),
                    width: checkboxWidth,
                    backgroundColor: Color(.Input.Background.disabled),
                    border: .regular(color: Color(.Input.Border.disabled))
                ),
                value: POTextStyle(color: Color(.Text.disabled), typography: valueTypography)
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
