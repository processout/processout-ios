//
//  POMessageView.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 03.06.2024.
//

import SwiftUI

@available(iOS 14.0, *)
@_spi(PO)
public struct POMessageView: View {

    public init(message: POMessage) {
        self.message = message
    }

    // MARK: - View

    public var body: some View {
        let configuration = POMessageViewStyleConfiguration(label: Text(message.text), severity: message.severity)
        AnyView(style.makeBody(configuration: configuration))
    }

    // MARK: - Private Properties

    private let message: POMessage

    @Environment(\.messageViewStyle)
    private var style
}
