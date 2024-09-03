//
//  MessageViewModel.swift
//  Example
//
//  Created by Andrii Vysotskyi on 30.08.2024.
//

struct MessageViewModel {

    enum Severity {
        case success, error
    }

    /// Message text.
    let text: String

    /// Message severity.
    let severity: Severity
}
