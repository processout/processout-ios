//
//  DefaultContentUnavailableViewLabelStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.01.2025.
//

import SwiftUI

@available(iOS 14.0, *)
@MainActor
struct DefaultContentUnavailableViewLabelStyle: LabelStyle {

    let title: POTextStyle, description: POTextStyle

    // MARK: - LabelStyle

    func makeBody(configuration: Configuration) -> some View {
        StyleBox(configuration: configuration, title: title, description: description)
    }
}

@available(iOS 14.0, *)
@MainActor
private struct StyleBox: View {

    init(configuration: LabelStyleConfiguration, title: POTextStyle, description: POTextStyle) {
        self.configuration = configuration
        self.title = title
        self.description = description
        self._iconScale = .init(wrappedValue: 1, relativeTo: title.typography.textStyle)
    }

    // MARK: - View

    var body: some View {
        VStack(spacing: POSpacing.large) {
            configuration.icon
                .scaledToFit()
                .frame(height: 36 * iconScale)
                .foregroundColor(description.color)
            configuration.title
                .textStyle(title)
        }
    }

    // MARK: - Private Properties

    private let configuration: LabelStyleConfiguration, title: POTextStyle, description: POTextStyle

    @POBackport.ScaledMetric
    private var iconScale: CGFloat
}
