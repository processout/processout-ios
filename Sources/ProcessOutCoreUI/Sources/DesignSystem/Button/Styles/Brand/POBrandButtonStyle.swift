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
@MainActor
@preconcurrency
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
        ButtonStyleBox(
            title: title,
            border: border,
            shadow: shadow,
            progressStyle: progressStyle,
            configuration: configuration
        )
    }
}

// Environments may not be propagated directly to ButtonStyle. Workaround is
// to wrap content into additional view and use environments as usual.
@available(iOS 14.0, *)
@MainActor
private struct ButtonStyleBox: View {

    /// Title style.
    let title: POTextStyle

    /// Border style.
    let border: POBorderStyle

    /// Shadow style.
    let shadow: POShadowStyle

    /// Progress view style.
    let progressStyle: any ProgressViewStyle

    /// Button style configuration.
    let configuration: ButtonStyleConfiguration

    // MARK: -

    var body: some View {
        // todo(andrii-vysotskyi): add overlay or accept configuration for disabled state if needed
        let isBrandColorLight = UIColor(brandColor).isLight() != false
        ZStack {
            if isLoading {
                ProgressView()
                    .poProgressViewStyle(progressStyle)
            } else {
                configuration.label
                    .labelStyle(ButtonLabelStyle(titleStyle: title))
            }
        }
        .padding(
            .init(horizontal: POSpacing.small, vertical: POSpacing.extraSmall)
        )
        .frame(minWidth: minSize, maxWidth: maxWidth, minHeight: minSize)
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
        .backport.geometryGroup()
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

    @Environment(\.poControlWidth)
    private var controlWidth

    // MARK: - Private Methods

    private var brandColor: Color {
        let interfaceStyle = UIUserInterfaceStyle(colorScheme)
        let traitCollection = UITraitCollection(userInterfaceStyle: interfaceStyle)
        return Color(uiBrandColor.resolvedColor(with: traitCollection))
    }

    private func brightnessAdjustment(isPressed: Bool, isBrandColorLight: Bool) -> Double {
        guard isPressed else {
            return 0
        }
        return isBrandColorLight ? -0.08 : 0.15 // Darken if color is light or brighten otherwise
    }

    private var minSize: CGFloat {
        let sizes: [POControlSize: CGFloat] = [.small: 32, .regular: 44]
        return sizes[controlSize]! // swiftlint:disable:this force_unwrapping
    }

    private var maxWidth: CGFloat? {
        let widths: [POControlWidth: CGFloat] = [.expanded: .infinity]
        return widths[controlWidth]
    }
}
