//
//  ProgressViewStyle+Step.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.04.2025.
//

import SwiftUI

// todo(andrii-vysotskyi): use colors from design system once available

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
                    backgroundColor: .init(light: .init(0xFFFFFF), dark: .init(0x121314, alpha: 0.2)),
                    border: .init(
                        radius: 9999,
                        width: 1.5,
                        color: .init(light: .init(0xCACACA), dark: .init(0xF6F8FB, alpha: 0.24))
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
                    backgroundColor: .init(light: .init(0xFFFFFF), dark: .init(0xFFFFFF)),
                    border: .init(
                        radius: 9999, width: 1.5, color: .init(light: .init(0xA3A3A3), dark: .init(0xA3A3A3))
                    ),
                    halo: .init(
                        color: Color(
                            light: UIColor(0x000000, alpha: 0.07), dark: UIColor(0xFFFFFF, alpha: 0.24)
                        ),
                        width: 6
                    )
                )
            ),
            completed: .init(
                label: .init(
                    color: Color.Text.positive,
                    typography: .Text.s15(weight: .medium)
                ),
                currentValueLabel: .init(
                    color: Color.Text.secondary,
                    typography: .Text.s12(weight: .medium)
                ),
                icon: .init(
                    checkmark: .init(color: .init(light: .init(0xFFFFFF), dark: .init(0xFFFFFF)), width: 2),
                    backgroundColor: .init(light: .init(0x4CA259), dark: .init(0x4CA259)),
                    border: .init(
                        radius: 9999, width: 1.5, color: Color(light: UIColor(0x4CA259), dark: UIColor(0x4CA259))
                    ),
                    halo: nil
                )
            )
        )
    }
}

@available(iOS 16.0, *)
#Preview {
    ProgressView(
        value: 0.3,
        label: {
            Text("Label")
        },
        currentValueLabel: {
            Text("Current value")
        }
    )
    .progressViewStyle(.poStep)
}
