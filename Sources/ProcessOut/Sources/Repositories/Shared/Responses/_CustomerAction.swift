//
//  CustomerAction.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.10.2022.
//

import Foundation

// todo(andrii-vysotskyi): remove underscore when legacy codebase is removed.
struct _CustomerAction: Decodable { // swiftlint:disable:this type_name

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
