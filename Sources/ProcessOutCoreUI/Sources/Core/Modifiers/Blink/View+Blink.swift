//
//  BlinkViewModifier.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 16.06.2024.
//

import SwiftUI

extension View {

    func blink(animation: Animation = .default) -> some View {
        modifier(BlinkViewModifier(animation: animation))
    }
}

private struct BlinkViewModifier: ViewModifier {

    let animation: Animation

    // MARK: - ViewModifier

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0.1)
            .onAppear {
                isVisible = false
            }
            .animation(animation.repeatForever(), value: isVisible)
    }

    // MARK: - Private Properties

    @State
    private var isVisible = true
}
