//
//  GroupBoxStyle+MultistepProgress.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.04.2025.
//

import SwiftUI

// todo(andrii-vysotskyi): use colors from design system

@_spi(PO)
@available(iOS 14.0, *)
extension GroupBoxStyle where Self == POMultistepProgressGroupBoxStyle {

    public static var poMultistepProgress: POMultistepProgressGroupBoxStyle {
        POMultistepProgressGroupBoxStyle(
            connector: .init(
                fromCompletedToCompleted: .init(
                    strokeColor: Color(red: 0.298, green: 0.635, blue: 0.349),
                    strokeStyle: StrokeStyle(lineWidth: 2)
                ),
                fromCompletedToAny: .init(
                    strokeColor: Color(red: 0.298, green: 0.635, blue: 0.349),
                    strokeStyle: StrokeStyle(lineWidth: 2, dash: [3, 3])
                ),
                default: .init(
                    strokeColor: Color(red: 0.792, green: 0.792, blue: 0.792),
                    strokeStyle: StrokeStyle(lineWidth: 2, dash: [3, 3])
                )
            )
        )
    }
}
