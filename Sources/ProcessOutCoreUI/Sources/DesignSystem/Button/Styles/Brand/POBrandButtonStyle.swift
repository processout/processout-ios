//
//  POBrandButtonStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 24.04.2024.
//

import SwiftUI

/// Brand button style that only requires base style information and resolves
/// styling for other states automatically.
///
/// - NOTE: SDK uses light color variation with light brand colors and dark otherwise.
@available(iOS 14, *)
public struct POBrandButtonStyle: ButtonStyle {

    /// Title style.
    public let title: POTextStyle

    /// Border style.
    public let border: POBorderStyle

    /// Shadow style.
    public let shadow: POShadowStyle

    /// Progress view style. Only used with normal state.
    public let progressStyle: any ProgressViewStyle

    /// Creates style instance.
    public init(
        title: POTextStyle,
        border: POBorderStyle,
        shadow: POShadowStyle,
        progressStyle: some ProgressViewStyle = .circular
    ) {
        self.title = title
        self.border = border
        self.shadow = shadow
        self.progressStyle = progressStyle
    }

    // MARK: - ButtonStyle

    public func makeBody(configuration: Configuration) -> some View {
        // todo(andrii-vysotskyi): add overlay or accept configuration for disabled state if needed
        ContentView { isEnabled, isLoading, brandColor, controlSize in
            let isBrandColorLight = UIColor(brandColor).isLight() != false
            ZStack {
                if isLoading {
                    ProgressView()
                        .poProgressViewStyle(progressStyle)
                } else {
                    configuration.label
                        .textStyle(title.scaledBy(labelTypographyScale(for: controlSize)))
                        .lineLimit(1)
                }
            }
            .padding(.init(horizontal: POSpacing.small, vertical: POSpacing.extraSmall))
            .frame(maxWidth: .infinity, minHeight: minHeight(for: controlSize))
            .backport.background {
                let adjustment = brightnessAdjustment(
                    isPressed: configuration.isPressed, isBrandColorLight: isBrandColorLight
                )
                brandColor.brightness(adjustment)
            }
            .border(style: border)
            .shadow(style: shadow)
            .colorScheme(isBrandColorLight ? .light : .dark)
            .contentShape(.rect)
            .animation(.default, value: isEnabled)
            .animation(.default, value: AnyHashable(brandColor))
            .allowsHitTesting(isEnabled)
        }
        .backport.geometryGroup()
    }

    // MARK: - Private Methods

    private func brightnessAdjustment(isPressed: Bool, isBrandColorLight: Bool) -> Double {
        guard isPressed else {
            return 0
        }
        return isBrandColorLight ? -0.08 : 0.15 // Darken if color is light or brighten otherwise
    }

    private func minHeight(for controlSize: POControlSize) -> CGFloat {
        switch controlSize {
        case .small:
            return 32
        case .regular:
            return 44
        }
    }

    private func labelTypographyScale(for controlSize: POControlSize) -> CGFloat {
        switch controlSize {
        case .small:
            return 0.85
        case .regular:
            return 1
        }
    }
}

// Environments are not propagated directly to ButtonStyle in any iOS before 14.5 workaround is
// to wrap content into additional view and extract them.
@available(iOS 14, *)
private struct ContentView<Content: View>: View {

    @ViewBuilder
    let content: (_ isEnabled: Bool, _ isLoading: Bool, _ brandColor: Color, _ controlSize: POControlSize) -> Content

    var body: some View {
        content(isEnabled, isLoading, brandColor, controlSize)
    }

    // MARK: - Private Properties

    @Environment(\.isEnabled)
    private var isEnabled

    @Environment(\.isButtonLoading)
    private var isLoading

    @Environment(\.poButtonBrandColor)
    private var uiBrandColor

    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.poControlSize)
    private var controlSize

    // MARK: - Private Methods

    private var brandColor: Color {
        let interfaceStyle = UIUserInterfaceStyle(colorScheme)
        let traitCollection = UITraitCollection(userInterfaceStyle: interfaceStyle)
        return Color(uiBrandColor.resolvedColor(with: traitCollection))
    }
}
