//
//  POProgressView.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 31.08.2023.
//

import SwiftUI
import UIKit

public struct POProgressView: View {

    public var body: some View {
        ProgressViewRepresentable(style: style).id(style)
    }

    // MARK: - Private Properties

    @Environment(\.progressViewStyle) private var style
}

extension View {

    /// Sets the style for progress views within this view.
    public func progressViewStyle(_ style: POProgressViewStyle) -> some View {
        environment(\.progressViewStyle, style)
    }
}

extension EnvironmentValues {

    var progressViewStyle: POProgressViewStyle {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Nested Types

    private struct Key: EnvironmentKey {
        static let defaultValue = POProgressViewStyle.system(.medium, color: nil)
    }
}

private struct ProgressViewRepresentable: UIViewRepresentable {

    let style: POProgressViewStyle

    func makeUIView(context: Context) -> UIView {
        switch style {
        case let .system(style, color):
            let uiView = UIActivityIndicatorView(style: style)
            uiView.startAnimating()
            uiView.color = color
            return uiView
        case .custom(let createView):
            return createView.makeView()
        }
    }

    func updateUIView(_ uiView: UIView, context: Context) { /* Ignored */ }
}
