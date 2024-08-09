//
//  DefaultDeviceMetadataProvider.swift
//  ProcessOut
//
//  Created by Simeon Kostadinov on 31/10/2022.
//

import UIKit

actor DefaultDeviceMetadataProvider: DeviceMetadataProvider {

    init(screen: UIScreen, device: UIDevice, bundle: Bundle, keychain: Keychain) {
        self.screen = screen
        self.device = device
        self.bundle = bundle
        self.keychain = keychain
    }

    // MARK: - DeviceMetadataProvider

    @MainActor var deviceMetadata: DeviceMetadata {
        get async {
            let metadata = DeviceMetadata(
                id: await deviceId,
                installationId: device.identifierForVendor?.uuidString,
                systemVersion: device.systemVersion,
                model: await machineName,
                appLanguage: bundle.preferredLocalizations.first!, // swiftlint:disable:this force_unwrapping
                appScreenWidth: Int(screen.nativeBounds.width), // Specified in pixels
                appScreenHeight: Int(screen.nativeBounds.height),
                appTimeZoneOffset: TimeZone.current.secondsFromGMT() / 60,
                channel: "ios"
            )
            return metadata
        }
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

    private lazy var machineName: String? = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let description = withUnsafePointer(to: &systemInfo.machine) { pointer in
            let capacity = Int(_SYS_NAMELEN)
            return pointer.withMemoryRebound(to: CChar.self, capacity: capacity) { charPointer in
                String(validatingCString: charPointer)
            }
        }
        return description
    }()

    private lazy var deviceId: String? = {
        if let deviceId = keychain.genericPassword(forAccount: Constants.keychainDeviceId) {
            return deviceId
        }
        let deviceId = UUID().uuidString
        keychain.add(genericPassword: deviceId, account: Constants.keychainDeviceId)
        return deviceId
    }()
}
