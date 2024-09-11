//
//  POLogger+Extensions.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 26.06.2023.
//

@testable @_spi(PO) import ProcessOut

extension POLogger {

    /// Stub logger.
    static let stub = POLogger(category: "")
}
