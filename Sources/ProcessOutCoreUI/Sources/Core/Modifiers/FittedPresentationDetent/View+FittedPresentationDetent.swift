//
//  View+F.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.12.2024.
//

import SwiftUI

extension View {

    /// Automatically adjusts presentation detents based on content height if possible.
    @ViewBuilder
    @_spi(PO)
    public func fittedPresentationDetent() -> some View {
        if #available(iOS 16, *) {
            modifier(ContentModifier())
        } else {
            self
        }
    }
}

@available(iOS 16, *)
private struct ContentModifier: ViewModifier {

    func body(content: Content) -> some View {
        ScrollView {
            content
                .onSizeChange { size in
                    withAnimation {
                        selectedPresentationDetent = .height(size.height)
                    }
                }
        }
        .modify { content in
            if #available(iOS 16.4, *) {
                content.scrollBounceBehavior(.basedOnSize)
            } else {
                content
            }
        }
        .presentationDetents([selectedPresentationDetent], selection: $selectedPresentationDetent)
    }

    // MARK: - Private Properties

    @State
    private var selectedPresentationDetent = PresentationDetent.height(1)
}
