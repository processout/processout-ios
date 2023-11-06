//
//  POCardUpdateInformation.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 06.11.2023.
//

public struct POCardUpdateInformation {

    /// Masked card number.
    /// - NOTE: Value will be displayed as is to the user.
    public let maskedNumber: String

    /// Preferred scheme previously selected by customer if any.
    public let preferredScheme: String?
}
