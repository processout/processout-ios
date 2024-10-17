//
//  POMessage.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 03.06.2024.
//

import Foundation

@_spi(PO)
public struct POMessage: Identifiable, Sendable {

    /// Message ID.
    public let id: String

    /// Message text.
    public let text: String

    /// Severity
    public let severity: POMessageSeverity

    public init(id: String, text: String, severity: POMessageSeverity = .error) {
        self.id = id
        self.text = text
        self.severity = severity
    }
}

/// Message severity.
public enum POMessageSeverity: Sendable {

    /// An error.
    case error
}
