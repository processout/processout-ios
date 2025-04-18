//
//  View+OnSizeChange.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 08.09.2023.
//

import SwiftUI

extension View {

    @_spi(PO)
    @MainActor
    @ViewBuilder
    public func onSizeChange(perform action: @escaping (CGSize) -> Void) -> some View {
        if #available(iOS 16.0, *) {
            onGeometryChange(for: CGSize.self, of: \.size) { newValue in
                action(newValue)
            }
        } else {
            modifier(SizeModifier(action: action))
        }
    }
}

@MainActor
private struct SizeModifier: ViewModifier {

    let action: (CGSize) -> Void

    func body(content: Content) -> some View {
        content.backport.background {
            GeometryReader { geometry in
                Color.clear.preference(key: SizePreferenceKey.self, value: geometry.size)
            }
            .onPreferenceChange(SizePreferenceKey.self) { size in
                MainActor.assumeIsolated {
                    if let size { action(size) }
                }
            }
        }
    }
}

private struct SizePreferenceKey: PreferenceKey {

    static func reduce(value: inout CGSize?, nextValue: () -> CGSize?) {
        if let nextValue = nextValue() {
            value = nextValue
        }
    }

    static let defaultValue: CGSize? = nil
}
