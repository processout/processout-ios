//
//  Constants.swift
//  Example
//
//  Created by Andrii Vysotskyi on 10.05.2023.
//

import Foundation
import ProcessOut

enum Constants {

    /// Project configuration.
    static var projectConfiguration = ProcessOutConfiguration(projectId: "")

    /// Customer ID.
    static var customerId = ""

    /// ApplePay merchant ID.
    static let merchantId: String? = nil

    /// Return URL.
    static let returnUrl = URL(string: "processout-example://return")! // swiftlint:disable:this force_unwrapping
}
