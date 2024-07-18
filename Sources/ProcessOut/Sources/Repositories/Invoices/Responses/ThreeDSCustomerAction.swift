//
//  ThreeDSCustomerAction.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.10.2022.
//

import Foundation

struct ThreeDSCustomerAction: Decodable, Sendable {

    enum ActionType: String, Decodable, Sendable {

        /// Device fingerprint is required.
        case fingerprintMobile = "fingerprint-mobile"

        /// Customer is required to complete challenge to continue.
        case challengeMobile = "challenge-mobile"

        /// Customer must be redirected to given URL to continue.
        case url, redirect

        /// Device fingerprint is required.
        case fingerprint
    }

    /// Action type.
    let type: ActionType

    /// Action value.
    let value: String
}
