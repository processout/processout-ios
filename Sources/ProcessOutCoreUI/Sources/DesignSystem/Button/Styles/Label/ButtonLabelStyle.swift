//
//  ButtonLabelStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.01.2025.
//

import SwiftUI

@available(iOS 14.0, *)
@MainActor
struct ButtonLabelStyle: LabelStyle {

    let titleStyle: POTextStyle

    // MARK: - LabelStyle

    func makeBody(configuration: Configuration) -> some View {
        ContentView(configuration: configuration, titleStyle: titleStyle)
    }
}

@available(iOS 14.0, *)
@MainActor
private struct ContentView: View {

    init(configuration: LabelStyleConfiguration, titleStyle: POTextStyle) {
        self.configuration = configuration
        self.titleStyle = titleStyle
        self._iconScale = .init(wrappedValue: 1, relativeTo: titleStyle.typography.textStyle)
    }

    // MARK: - View

    var body: some View {
        Label {
            configuration.title
                .lineLimit(1)
                .textStyle(scaledTitleStyle)
        } icon: {
            configuration.icon
                .foregroundColor(titleStyle.color)
                .scaledToFit()
                .frame(height: scaledIconHeight)
        }
    }

    // MARK: - Private Properties

    private let configuration: LabelStyleConfiguration, titleStyle: POTextStyle

    @Environment(\.controlSize)
    private var controlSize

    @POBackport.ScaledMetric
    private var iconScale: CGFloat

    // MARK: - Private Methods

    private var scaledIconHeight: CGFloat {
        switch controlSize {
        case .mini, .small:
            return 16 * iconScale
        default:
            return 20 * iconScale
        }
    }

    private var scaledTitleStyle: POTextStyle {
        switch controlSize {
        case .mini, .small:
            return titleStyle.scaledBy(0.867)
        default:
            return titleStyle
        }
    }
}
