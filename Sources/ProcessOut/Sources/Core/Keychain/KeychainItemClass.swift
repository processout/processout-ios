//
//  KeychainItemClass.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 31.05.2023.
//

import Security

struct KeychainItemClass: RawRepresentable {

    let rawValue: CFString

    /// Generic password item.
    static let genericPassword = KeychainItemClass(rawValue: kSecClassGenericPassword)
}
