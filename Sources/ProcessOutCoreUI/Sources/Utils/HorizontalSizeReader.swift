//
//  HorizontalSizeReader.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 21.09.2023.
//

import SwiftUI

struct HorizontalSizeReader<Content: View>: View {

    @ViewBuilder
    let content: (CGFloat) -> Content

    var body: some View {
        content(width)
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(
                GeometryReader { geometry in
                    Color.clear.preference(key: WidthPreferenceKey.self, value: geometry.size.width)
                }
            )
            .onPreferenceChange(WidthPreferenceKey.self) { width in
                self.width = width
            }
    }

    // MARK: - Private Properties

    @State
    private var width: CGFloat = 0
}

private struct WidthPreferenceKey: PreferenceKey, Equatable {

    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        // An empty reduce implementation takes the first value
    }
}
