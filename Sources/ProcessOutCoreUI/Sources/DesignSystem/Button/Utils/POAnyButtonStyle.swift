//
//  POAnyButtonStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 20.10.2023.
//

import SwiftUI

/// The `POAnyButtonStyle` type forwards body creation to an underlying style value,
/// hiding the type of the wrapped value.
@_spi(PO)
public struct POAnyButtonStyle: ButtonStyle {

    public init(erasing style: any ButtonStyle) {
        self.style = style
    }

    public func makeBody(configuration: Configuration) -> some View {
        AnyView(style.makeBody(configuration: configuration))
    }

    // MARK: - Private Properties

    private let style: any ButtonStyle
}
