//
//  POAutomaticNativeAlternativePaymentSuccessViewStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.06.2025.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

public struct POAutomaticNativeAlternativePaymentSuccessViewStyle: PONativeAlternativePaymentSuccessViewStyle { // swiftlint:disable:this type_name line_length

    public init(title: POTextStyle, description: POTextStyle) {
        self.title = title
        self.description = description
    }

    public init() {
        self.title = .init(color: .Text.primary, typography: .Text.s20(weight: .semibold))
        self.description = .init(color: .Text.secondary, typography: .Paragraph.s16(weight: .regular))
    }

    // MARK: - PONativeAlternativePaymentSuccessViewStyle

    public func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: POSpacing.space6) {
            Image(poResource: .success)
            configuration.title
                .textStyle(title)
            configuration.description
                .textStyle(description)
        }
        .padding(.top, POSpacing.space28)
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }

    // MARK: - Private Properties

    private let title: POTextStyle
    private let description: POTextStyle
}
