//
//  POLogger+Extensions.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 26.06.2023.
//

@_spi(PO) @testable import ProcessOut

extension POLogger {

    /// Stub logger.
    static var stub = POLogger(category: "")
}
