//
//  POMessageViewStyleConfiguration.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 03.06.2024.
//

import SwiftUI

public struct POMessageViewStyleConfiguration {

    /// A view that describes the message text.
    public let label: AnyView

    /// Message severity.
    public let severity: POMessageSeverity

    init(label: some View, severity: POMessageSeverity) {
        self.label = AnyView(label)
        self.severity = severity
    }
}
