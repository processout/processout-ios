//
//  DefaultDeviceMetadataProvider.swift
//  ProcessOut
//
//  Created by Simeon Kostadinov on 31/10/2022.
//

import UIKit
import Security

final class DefaultDeviceMetadataProvider: DeviceMetadataProvider {

    init(screen: UIScreen, device: UIDevice, bundle: Bundle) {
        self.screen = screen
        self.device = device
        self.bundle = bundle
    }

    // MARK: - DeviceMetadataProvider

    var deviceMetadata: DeviceMetadata {
        DeviceMetadata(
            id: .init(value: deviceId),
            installationId: .init(value: device.identifierForVendor?.uuidString),
            systemVersion: .init(value: device.systemVersion),
            appLanguage: bundle.preferredLocalizations.first!, // swiftlint:disable:this force_unwrapping
            appScreenWidth: Int(screen.nativeBounds.width), // Specified in pixels
            appScreenHeight: Int(screen.nativeBounds.height),
            appTimeZoneOffset: TimeZone.current.secondsFromGMT() / 60,
            channel: device.systemName.lowercased()
        )
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let keychainDeviceIdKey = "DeviceId"
        static let keychainService = "com.processout"
    }

    // MARK: - Private Properties

    private let screen: UIScreen
    private let device: UIDevice
    private let bundle: Bundle

    private lazy var deviceId: String? = {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: Constants.keychainDeviceIdKey,
            kSecAttrService: Constants.keychainService,
            kSecReturnData: true
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecSuccess, let data = result as? Data {
            return String(decoding: data, as: UTF8.self)
        }
        guard status == errSecItemNotFound else {
            return nil // Failed to retrieve item
        }
        let deviceId = UUID().uuidString
        addDeviceId(deviceId)
        return deviceId
    }()

    // MARK: - Private Methods

    @discardableResult
    private func addDeviceId(_ deviceId: String) -> Bool {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecValueData: Data(deviceId.utf8),
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            kSecAttrAccount: Constants.keychainDeviceIdKey,
            kSecAttrService: Constants.keychainService
        ]
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }
}
