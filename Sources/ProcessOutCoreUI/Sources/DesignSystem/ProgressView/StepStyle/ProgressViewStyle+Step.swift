//
//  ProgressViewStyle+Step.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.04.2025.
//

import SwiftUI

// todo(andrii-vysotskyi): use colors from design system once available

@_spi(PO)
@available(iOS 14.0, *)
extension ProgressViewStyle where Self == POStepProgressViewStyle {

    public static var poStep: POStepProgressViewStyle {
        POStepProgressViewStyle(
            notStarted: .init(
                label: .init(
                    color: Color.Text.tertiary,
                    typography: .Text.s15(weight: .medium)
                ),
                currentValueLabel: .init(
                    color: Color.Text.tertiary,
                    typography: .Text.s12(weight: .medium)
                ),
                icon: .init(
                    checkmark: nil,
                    backgroundColor: .clear,
                    border: .init(
                        radius: 9999, width: 1.5, color: Color(red: 0.792, green: 0.792, blue: 0.792)
                    ),
                    halo: nil
                )
            ),
            started: .init(
                label: .init(
                    color: Color.Text.primary,
                    typography: .Text.s15(weight: .medium)
                ),
                currentValueLabel: .init(
                    color: Color.Text.secondary,
                    typography: .Text.s12(weight: .medium)
                ),
                icon: .init(
                    checkmark: nil,
                    backgroundColor: .white,
                    border: .init(
                        radius: 9999, width: 1.5, color: Color(red: 0.792, green: 0.792, blue: 0.792)
                    ),
                    halo: .init(color: Color.black.opacity(0.07), width: 6)
                )
            ),
            completed: .init(
                label: .init(
                    color: Color.Text.positive,
                    typography: .Text.s15(weight: .medium)
                ),
                currentValueLabel: .init(
                    color: Color.Text.positive,
                    typography: .Text.s12(weight: .medium)
                ),
                icon: .init(
                    checkmark: .init(color: .white, width: 2),
                    backgroundColor: Color(red: 0.298, green: 0.635, blue: 0.349),
                    border: .init(
                        radius: 9999, width: 1.5, color: Color(red: 0.298, green: 0.635, blue: 0.349)
                    ),
                    halo: nil
                )
            )
        )
    }
}
