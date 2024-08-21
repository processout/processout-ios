//
//  Constants.swift
//  Example
//
//  Created by Andrii Vysotskyi on 10.05.2023.
//

import Foundation

enum Constants {

    /// Project ID.
    static let projectId = ""

    /// Project private key.
    static let projectPrivateKey = ""

    /// Customer ID.
    static let customerId = ""

    /// ApplePay merchant ID.
    static let merchantId: String? = nil

    /// Return URL.
    static let returnUrl = URL(string: "processout-example://return")! // swiftlint:disable:this force_unwrapping
}
