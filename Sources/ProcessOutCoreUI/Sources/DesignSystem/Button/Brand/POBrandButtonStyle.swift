//
//  POBrandButtonStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 24.04.2024.
//

import SwiftUI

/// Brand button style that only requires base style information and resolves
/// styling for other states automatically.
@available(iOS 14, *)
public struct POBrandButtonStyle: ButtonStyle {

    /// Title style.
    public let title: POTextStyle

    /// Border style.
    public let border: POBorderStyle

    /// Shadow style.
    public let shadow: POShadowStyle

    /// Creates style instance.
    public init(title: POTextStyle, border: POBorderStyle, shadow: POShadowStyle) {
        self.title = title
        self.border = border
        self.shadow = shadow
    }

    // MARK: - ButtonStyle

    public func makeBody(configuration: Configuration) -> some View {
        // todo(andrii-vysotskyi): add overlay or accept configuration for disabled state if needed
        ContentView { isEnabled, brandColor in
            let isBrandColorLight = UIColor(brandColor).isLight() != false
            configuration.label
                .textStyle(title)
                .colorScheme(isBrandColorLight ? .light : .dark)
                .multilineTextAlignment(.center)
                .padding(Constants.padding)
                .frame(maxWidth: .infinity, minHeight: Constants.minHeight)
                .backport.background {
                    let adjustment = brightnessAdjustment(
                        isPressed: configuration.isPressed, isBrandColorLight: isBrandColorLight
                    )
                    brandColor.brightness(adjustment)
                }
                .border(style: border)
                .shadow(style: shadow)
                .contentShape(.rect)
                .animation(.default, value: isEnabled)
                .animation(.default, value: AnyHashable(brandColor))
                .allowsHitTesting(isEnabled)
        }
        .backport.geometryGroup()
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let padding = EdgeInsets(
            top: POSpacing.extraSmall,
            leading: POSpacing.small,
            bottom: POSpacing.extraSmall,
            trailing: POSpacing.small
        )
        static let minHeight: CGFloat = 44
    }

    // MARK: - Private Methods

    private func brightnessAdjustment(isPressed: Bool, isBrandColorLight: Bool) -> Double {
        guard isPressed else {
            return 0
        }
        return isBrandColorLight ? -0.08 : 0.15 // Darken if color is light or brighten otherwise
    }
}

// Environments are not propagated directly to ButtonStyle in any iOS before 14.5 workaround is
// to wrap content into additional view and extract them.
private struct ContentView<Content: View>: View {

    @ViewBuilder
    let content: (_ isEnabled: Bool, _ brandColor: Color) -> Content

    var body: some View {
        content(isEnabled, brandColor)
    }

    // MARK: - Private Properties

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.poButtonBrandColor) private var brandColor
}
