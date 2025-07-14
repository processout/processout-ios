//
//  GroupBoxStyle+MultistepProgress.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.04.2025.
//

import SwiftUI

extension GroupBoxStyle where Self == POMultistepProgressGroupBoxStyle {

    public static var poMultistepProgress: POMultistepProgressGroupBoxStyle {
        POMultistepProgressGroupBoxStyle(
            connector: .init(
                fromCompletedToCompleted: .init(
                    strokeColor: Color(light: UIColor(0x139947), dark: UIColor(0x28DE6B)),
                    strokeStyle: StrokeStyle(lineWidth: 2)
                ),
                fromCompletedToAny: .init(
                    strokeColor: Color(light: UIColor(0x21222229, alpha: 0.16), dark: UIColor(0xF6F8FB, alpha: 0.2)),
                    strokeStyle: StrokeStyle(lineWidth: 2, dash: [3, 3])
                ),
                default: .init(
                    strokeColor: Color(light: UIColor(0x21222229, alpha: 0.16), dark: UIColor(0xF6F8FB, alpha: 0.2)),
                    strokeStyle: StrokeStyle(lineWidth: 2, dash: [3, 3])
                )
            )
        )
    }
}
