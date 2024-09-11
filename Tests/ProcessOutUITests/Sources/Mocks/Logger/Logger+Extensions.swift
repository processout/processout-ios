//
//  Logger+Extensions.swift
//  ProcessOutUITests
//
//  Created by Andrii Vysotskyi on 14.11.2023.
//

@testable @_spi(PO) import ProcessOut

extension POLogger {

    /// Stub logger.
    static let stub = POLogger(category: "")
}
