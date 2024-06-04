//
//  POMessage.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 03.06.2024.
//

@_spi(PO)
public struct POMessage {

    /// Message text.
    public let text: String

    /// Severity
    public let severity: POMessageSeverity

    public init(text: String, severity: POMessageSeverity = .error) {
        self.text = text
        self.severity = severity
    }
}

public enum POMessageSeverity {

    /// An error.
    case error
}
