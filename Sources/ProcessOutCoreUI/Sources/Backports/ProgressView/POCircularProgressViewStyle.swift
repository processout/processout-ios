//
//  POCircularProgressViewStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 12.10.2023.
//

import SwiftUI

@available(iOS, deprecated: 14)
public struct POCircularProgressViewStyle: POProgressViewStyle {

    public init(style: UIActivityIndicatorView.Style, tint: UIColor?) {
        self.style = style
        self.tint = tint
    }

    public func makeBody() -> some View {
        ActivityIndicatorViewRepresentable(style: style, color: tint)
    }

    // MARK: - Private Properties

    private let style: UIActivityIndicatorView.Style
    private let tint: UIColor?
}

extension POProgressViewStyle where Self == POCircularProgressViewStyle {

    public static func circular(
        style: UIActivityIndicatorView.Style = .medium, tint: UIColor? = nil
    ) -> POCircularProgressViewStyle {
        POCircularProgressViewStyle(style: style, tint: tint)
    }
}

private struct ActivityIndicatorViewRepresentable: UIViewRepresentable {

    let style: UIActivityIndicatorView.Style
    let color: UIColor?

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let uiView = UIActivityIndicatorView(style: style)
        uiView.startAnimating()
        uiView.hidesWhenStopped = false
        return uiView
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        uiView.style = style
        uiView.color = color
    }
}
