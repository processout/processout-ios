//
//  ViewThatExists.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.05.2025.
//

import SwiftUI

/// A container view that renders the first non-empty subview from the given content.
///
/// Use this when you want to present the first available view from a list of conditionally
/// constructed views.
struct ViewThatExists<Content: View>: View {

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    // MARK: - View

    var body: some View {
        Group(poSubviews: content) { subviews in
            if let first = subviews.first {
                first
            }
        }
    }

    // MARK: - Private Properties

    private let content: Content
}
