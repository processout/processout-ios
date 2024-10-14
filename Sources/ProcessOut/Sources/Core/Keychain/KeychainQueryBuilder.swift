//
//  KeychainQueryBuilder.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 31.05.2023.
//

import Foundation
import Security

struct KeychainQueryBuilder: Sendable {

    /// Item's class.
    var itemClass: KeychainItemClass = .genericPassword

    /// Indicates when the keychain item is accessible.
    var accessibility: KeychainItemAccessibility = .accessibleAfterFirstUnlockThisDeviceOnly

    /// String indicating the item's service.
    var service: String?

    /// String indicating the item's account name.
    var account: String?

    /// Item's data.
    var valueData: Data?

    /// Indicating whether or not to return item data.
    var shouldReturnData: Bool?

    func build() -> CFDictionary {
        var query: [CFString: Any] = [
            kSecClass: itemClass.rawValue,
            kSecAttrAccessible: accessibility.rawValue
        ]
        query[kSecAttrService] = service
        query[kSecAttrAccount] = account
        query[kSecValueData] = valueData
        query[kSecReturnData] = shouldReturnData
        return query as CFDictionary
    }
}
