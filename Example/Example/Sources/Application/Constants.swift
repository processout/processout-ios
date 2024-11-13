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
    @UserDefaultsStorage("Constants.projectConfiguration")
    static var projectConfiguration = ProcessOutConfiguration(projectId: "")

    /// Customer ID.
    @UserDefaultsStorage("Constants.customerId")
    static var customerId = ""

    /// ApplePay merchant ID.
    @UserDefaultsStorage("Constants.merchantId")
    static var merchantId: String?

    /// Return URL.
    static let returnUrl = URL(string: "processout-example://return")! // swiftlint:disable:this force_unwrapping
}
