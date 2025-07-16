//
//  ProgressViewStyle+Step.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.04.2025.
//

import SwiftUI

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
                    backgroundColor: .init(light: .init(0xFFFFFF), dark: .init(0x26292F)),
                    border: .init(
                        radius: 9999,
                        width: 1.5,
                        color: .init(light: .init(0x8A8D93), dark: .init(0x707378))
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
                    backgroundColor: .init(light: .init(0xFFFFFF), dark: .init(0x26292F)),
                    border: .init(
                        radius: 9999, width: 1.5, color: .init(light: .init(0x8A8D93), dark: .init(0x707378))
                    ),
                    halo: .init(
                        color: Color(
                            light: UIColor(0x121314, alpha: 0.08), dark: UIColor(0xF6F8FB1F, alpha: 0.12)
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
                    checkmark: .init(color: .init(light: .init(0xFFFFFF), dark: .init(0x000000)), width: 2),
                    backgroundColor: .init(light: .init(0x1ABE5A), dark: .init(0x28DE6B)),
                    border: .init(
                        radius: 9999, width: 1.5, color: Color(light: UIColor(0x1ABE5A), dark: UIColor(0x28DE6B))
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
