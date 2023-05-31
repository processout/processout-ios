//
//  DefaultDeviceMetadataProvider.swift
//  ProcessOut
//
//  Created by Simeon Kostadinov on 31/10/2022.
//

import UIKit

final class DefaultDeviceMetadataProvider: DeviceMetadataProvider {

    init(screen: UIScreen, device: UIDevice, bundle: Bundle, userDefaults: UserDefaults) {
        self.screen = screen
        self.device = device
        self.bundle = bundle
        self.userDefaults = userDefaults
    }

    // MARK: - DeviceMetadataProvider

    var deviceMetadata: DeviceMetadata {
        DeviceMetadata(
            id: .init(value: ""),
            installationId: .init(value: installationId),
            appLanguage: bundle.preferredLocalizations.first!, // swiftlint:disable:this force_unwrapping
            appScreenWidth: Int(screen.nativeBounds.width), // Specified in pixels
            appScreenHeight: Int(screen.nativeBounds.height),
            appTimeZoneOffset: TimeZone.current.secondsFromGMT() / 60,
            channel: device.systemName.lowercased()
        )
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let installationIdKey = "InstallationId"
    }

    // MARK: - Private Properties

    private let screen: UIScreen
    private let device: UIDevice
    private let bundle: Bundle
    private let userDefaults: UserDefaults

    private lazy var installationId: String = {
        if let installationId = userDefaults.string(forKey: Constants.installationIdKey) {
            return installationId
        }
        let installationId = UUID().uuidString
        userDefaults.set(installationId, forKey: Constants.installationIdKey)
        return installationId
    }()

    // MARK: - Private Methods
}
