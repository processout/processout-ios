//
//  Keychain.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 31.05.2023.
//

import Foundation
import Security

final class Keychain: Sendable {

    init(service: String) {
        queryBuilder = KeychainQueryBuilder(service: service)
    }

    @discardableResult
    func add(genericPassword: String, account: String) -> Bool {
        var builder = queryBuilder
        builder.valueData = Data(genericPassword.utf8)
        builder.account = account
        return SecItemAdd(builder.build() as CFDictionary, nil) == errSecSuccess
    }

    func genericPassword(forAccount account: String) -> String? {
        var builder = queryBuilder
        builder.account = account
        builder.shouldReturnData = true
        var result: AnyObject?
        let status = SecItemCopyMatching(builder.build() as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }
        return String(decoding: data, as: UTF8.self)
    }

    // MARK: - Private Properties

    private let queryBuilder: KeychainQueryBuilder
}
