//
//  ProgressViewStyle+Step.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.04.2025.
//

import SwiftUI

// todo(andrii-vysotskyi): use colors from design system

@available(iOS 14.0, *)
extension ProgressViewStyle where Self == POStepProgressViewStyle {

    public static var poStep: POStepProgressViewStyle {
        POStepProgressViewStyle(
            notStarted: .init(
                label: .init(
                    color: Color(red: 134 / 255, green: 134 / 255, blue: 134 / 255),
                    typography: .Text.s15(weight: .medium)
                ),
                currentValueLabel: .init(
                    color: Color(red: 134 / 255, green: 134 / 255, blue: 134 / 255),
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
                    color: Color(red: 88 / 255, green: 90 / 255, blue: 95 / 255),
                    typography: .Text.s15(weight: .medium)
                ),
                currentValueLabel: .init(
                    color: Color(red: 134 / 255, green: 134 / 255, blue: 134 / 255),
                    typography: .Text.s12(weight: .medium)
                ),
                icon: .init(
                    checkmark: nil,
                    backgroundColor: .white,
                    border: .init(
                        radius: 9999, width: 1.5, color: Color(red: 0.792, green: 0.792, blue: 0.792)
                    ),
                    halo: .init(color: Color.black.opacity(0.08), width: 6)
                )
            ),
            completed: .init(
                label: .init(
                    color: Color(red: 76 / 255, green: 162 / 255, blue: 89 / 255),
                    typography: .Text.s15(weight: .medium)
                ),
                currentValueLabel: .init(
                    color: Color(red: 76 / 255, green: 162 / 255, blue: 89 / 255),
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
