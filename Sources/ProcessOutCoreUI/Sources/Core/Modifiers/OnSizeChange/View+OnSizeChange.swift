//
//  View+OnSizeChange.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 08.09.2023.
//

#if DEBUG

import SwiftUI

extension View {

    @MainActor
    func onSizeChange(perform action: @escaping (CGSize) -> Void) -> some View {
        modifier(SizeModifier(action: action))
    }
}

@MainActor
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

    static let defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

#endif
