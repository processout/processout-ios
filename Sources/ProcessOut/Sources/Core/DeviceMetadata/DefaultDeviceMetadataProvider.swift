//
//  DefaultDeviceMetadataProvider.swift
//  ProcessOut
//
//  Created by Simeon Kostadinov on 31/10/2022.
//

import UIKit

final class DefaultDeviceMetadataProvider: DeviceMetadataProvider {

    init(screen: UIScreen, device: UIDevice, bundle: Bundle) {
        self.screen = screen
        self.device = device
        self.bundle = bundle
    }

    // MARK: - DeviceMetadataProvider

    var deviceMetadata: DeviceMetadata {
        DeviceMetadata(
            id: .init(value: ""),
            installationId: .init(value: device.identifierForVendor?.uuidString),
            systemVersion: .init(value: device.systemVersion),
            appLanguage: bundle.preferredLocalizations.first!, // swiftlint:disable:this force_unwrapping
            appScreenWidth: Int(screen.nativeBounds.width), // Specified in pixels
            appScreenHeight: Int(screen.nativeBounds.height),
            appTimeZoneOffset: TimeZone.current.secondsFromGMT() / 60,
            channel: device.systemName.lowercased()
        )
    }

    // MARK: - Private Properties

    private let screen: UIScreen
    private let device: UIDevice
    private let bundle: Bundle
}
