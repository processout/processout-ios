//
//  ButtonLabelStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.01.2025.
//

import SwiftUI

@available(iOS 14.0, *)
struct ButtonLabelStyle: LabelStyle {

    let titleStyle: POTextStyle

    // MARK: - LabelStyle

    func makeBody(configuration: Configuration) -> some View {
        ContentView(configuration: configuration, titleStyle: titleStyle)
    }
}

@available(iOS 14.0, *)
private struct ContentView: View {

    let configuration: LabelStyleConfiguration, titleStyle: POTextStyle

    // MARK: - View

    var body: some View {
        Label {
            configuration.title
                .lineLimit(1)
                .textStyle(scaledTitleStyle)
        } icon: {
            configuration.icon
                .scaledToFit()
                .frame(maxHeight: scaledIconMaxHeight)
        }
    }

    // MARK: - Private Properties

    @Environment(\.poControlSize)
    private var controlSize

    @POBackport.ScaledMetric
    private var iconScale: CGFloat = 1

    // MARK: - Private Methods

    private var scaledIconMaxHeight: CGFloat {
        let sizes: [POControlSize: CGFloat] = [.regular: 20, .small: 16]
        return sizes[controlSize]! * iconScale // swiftlint:disable:this force_unwrapping
    }

    private var scaledTitleStyle: POTextStyle {
        let scales: [POControlSize: CGFloat] = [.regular: 1, .small: 0.867]
        let scale = scales[controlSize]! // swiftlint:disable:this force_unwrapping
        return titleStyle.scaledBy(scale)
    }
}
