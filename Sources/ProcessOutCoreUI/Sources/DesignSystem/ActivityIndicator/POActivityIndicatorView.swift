//
//  ActivityIndicatorView.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 31.08.2023.
//

import SwiftUI
import UIKit

public struct POActivityIndicatorView: UIViewRepresentable {

    public func makeUIView(context: Context) -> UIView {
        switch style {
        case let .system(style, color):
            let uiView = UIActivityIndicatorView(style: style)
            uiView.startAnimating()
            uiView.color = color
            return uiView
        case .custom(let createView):
            return createView()
        }
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        // todo(andrii-vysotskyi): when style changes view won't be recreated so implementation should be able
        // to update previously created one.
    }

    // MARK: - Private Properties

    @Environment(\.activityIndicatorStyle) private var style
}

extension View {

    /// Sets the style for activity indicators within this view.
    public func activityIndicatorStyle(_ style: POActivityIndicatorStyle) -> some View {
        environment(\.activityIndicatorStyle, style)
    }
}

extension EnvironmentValues {

    var activityIndicatorStyle: POActivityIndicatorStyle {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Nested Types

    private struct Key: EnvironmentKey {
        static let defaultValue = POActivityIndicatorStyle.system(.medium, color: nil)
    }
}
