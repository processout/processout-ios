//
//  DefaultDeviceMetadataProvider.swift
//  ProcessOut
//
//  Created by Simeon Kostadinov on 31/10/2022.
//

import UIKit
import Security

final class DefaultDeviceMetadataProvider: DeviceMetadataProvider {

    init(screen: UIScreen, device: UIDevice, bundle: Bundle, keychain: Keychain) {
        self.screen = screen
        self.device = device
        self.bundle = bundle
        self.keychain = keychain
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
        static let keychainDeviceId = "DeviceId"
    }

    // MARK: - Private Properties

    private let screen: UIScreen
    private let device: UIDevice
    private let bundle: Bundle
    private let keychain: Keychain

    private lazy var deviceId: String? = {
        if let deviceId = keychain.genericPassword(forAccount: Constants.keychainDeviceId) {
            return deviceId
        }
        let deviceId = UUID().uuidString
        keychain.add(genericPassword: deviceId, account: Constants.keychainDeviceId)
        return deviceId
    }()
}
