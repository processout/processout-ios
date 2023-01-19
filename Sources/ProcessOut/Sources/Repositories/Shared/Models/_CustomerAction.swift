//
//  _CustomerAction.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.10.2022.
//

import Foundation

// swiftlint:disable type_name todo
// - TODO: Remove underscore when legacy counterpart won't be needed.
struct _CustomerAction: Decodable {

    enum ActionType: String, Decodable {

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
