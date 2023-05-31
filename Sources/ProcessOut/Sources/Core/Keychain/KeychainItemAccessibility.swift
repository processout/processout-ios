//
//  KeychainItemAccessibility.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 31.05.2023.
//

import Security

struct KeychainItemAccessibility: RawRepresentable {

    let rawValue: CFString

    /// The data in the keychain item cannot be accessed after a restart until
    /// the device has been unlocked once by the user.
    static let accessibleAfterFirstUnlockThisDeviceOnly = KeychainItemAccessibility(
        rawValue: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    )
}
