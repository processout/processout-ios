//
//  POHorizontalSizeReader.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 21.09.2023.
//

import SwiftUI

@_spi(PO) public struct POHorizontalSizeReader<Content: View>: View {

    public init(@ViewBuilder content: @escaping (CGFloat) -> Content) {
        self.content = content
        self.width = width
    }

    public var body: some View {
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

    private let content: (CGFloat) -> Content

    @State
    private var width: CGFloat = 0
}

private struct WidthPreferenceKey: PreferenceKey, Equatable {

    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        // An empty reduce implementation takes the first value
    }
}
