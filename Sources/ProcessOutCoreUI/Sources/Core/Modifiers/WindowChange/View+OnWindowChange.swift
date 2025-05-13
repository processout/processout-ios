//
//  View+OnWindowChange.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.02.2025.
//

import SwiftUI

extension View {

    func onWindowChange(_ action: @escaping (UIWindow?) -> Void) -> some View {
        background(WindowContentViewRepresentable(onWindowChange: action))
    }
}

private struct WindowContentViewRepresentable: UIViewRepresentable {

    let onWindowChange: (UIWindow?) -> Void

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> WindowChangeContentView {
        WindowChangeContentView()
    }

    func updateUIView(_ uiView: WindowChangeContentView, context: Context) {
        uiView.onWindowChange = onWindowChange
    }

    static func dismantleUIView(_ uiView: WindowChangeContentView, coordinator: Void) {
        uiView.onWindowChange = nil
    }
}

private final class WindowChangeContentView: UIView {

    /// Action to invoke when window changes.
    var onWindowChange: ((UIWindow?) -> Void)?

    // MARK: -

    override func didMoveToWindow() {
        super.didMoveToWindow()
        onWindowChange?(window)
    }
}
