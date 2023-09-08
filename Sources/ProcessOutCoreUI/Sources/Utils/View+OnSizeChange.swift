//
//  View+OnSizeChange.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 08.09.2023.
//

import SwiftUI

extension View {

    func onSizeChange(perform action: @escaping (CGSize) -> Void) -> some View {
        modifier(SizeModifier(action: action))
    }
}

private struct SizeModifier: ViewModifier {

    let action: (CGSize) -> Void

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear.preference(key: SizePreferenceKey.self, value: geometry.size)
                }
            )
            .onPreferenceChange(SizePreferenceKey.self) { size in
                action(size)
            }
    }
}

private struct SizePreferenceKey: PreferenceKey {

    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
