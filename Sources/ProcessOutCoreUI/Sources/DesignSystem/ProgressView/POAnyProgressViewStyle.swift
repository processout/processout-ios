//
//  POAnyProgressViewStyle.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 07.11.2023.
//

import SwiftUI

/// The `POAnyProgressViewStyle` type forwards body creation to an underlying style value,
/// hiding the type of the wrapped value.
@available(iOS 14, *)
@_spi(PO) public struct POAnyProgressViewStyle: ProgressViewStyle {

    public init(erasing style: any ProgressViewStyle) {
        self.style = style
    }

    public func makeBody(configuration: Configuration) -> AnyView {
        AnyView(style.makeBody(configuration: configuration))
    }

    // MARK: - Private Properties

    private let style: any ProgressViewStyle
}
