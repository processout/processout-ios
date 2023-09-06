//
//  ActivityIndicatorView.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 31.08.2023.
//

import SwiftUI
import UIKit

public struct ActivityIndicatorView: UIViewRepresentable {

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
        // Ignored
    }

    // MARK: - Private Properties

    @Environment(\.activityIndicatorStyle) private var style
}

extension View {

    /// Sets the style for buttons within this view to a button style with a
    /// custom appearance and standard interaction behavior.
    public func activityIndicatorStyle(_ style: POActivityIndicatorStyle) -> some View {
        environment(\.activityIndicatorStyle, style)
    }
}

extension EnvironmentValues {

    /// A Boolean value that indicates whether the button associated with this
    /// environment shows loading indicator. Only applicable with `POButtonStyle`.
    ///
    /// The default value is `false`.
    public var activityIndicatorStyle: POActivityIndicatorStyle {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Nested Types

    private struct Key: EnvironmentKey {
        static let defaultValue = POActivityIndicatorStyle.system(.medium, color: nil)
    }
}
