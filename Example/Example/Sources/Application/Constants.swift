//
//  Constants.swift
//  Example
//
//  Created by Andrii Vysotskyi on 10.05.2023.
//

import Foundation
import ProcessOut

@MainActor
enum Constants {

    /// Project configuration.
    static var projectConfiguration = ProcessOutConfiguration(projectId: "")

    /// Customer ID.
    static var customerId = ""

    /// ApplePay merchant ID.
    static var merchantId: String?

    /// Return URL.
    static let returnUrl = URL(string: "processout-example://return")! // swiftlint:disable:this force_unwrapping
}
