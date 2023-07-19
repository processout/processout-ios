//
//  PaymentCardNumberFormat.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.07.2023.
//

struct PaymentCardNumberFormat {

    /// Acceptable leading digit ranges.
    let leading: [ClosedRange<Int>]

    /// Formatting paterns.
    let patterns: [String]
}
