//
//  DefaultDeviceMetadataProvider.swift
//  ProcessOut
//
//  Created by Simeon Kostadinov on 31/10/2022.
//

import UIKit

final class DefaultDeviceMetadataProvider: DeviceMetadataProvider {

    init(screen: UIScreen, bundle: Bundle) {
        self.screen = screen
        self.bundle = bundle
        timeZone = .autoupdatingCurrent
    }

    // MARK: - DeviceMetadataProvider

    var deviceMetadata: DeviceMetadata {
        DeviceMetadata(
            appLanguage: bundle.preferredLocalizations.first!, // swiftlint:disable:this force_unwrapping
            appScreenWidth: Int(screen.nativeBounds.width), // Specified in pixels
            appScreenHeight: Int(screen.nativeBounds.height),
            appTimeZoneOffset: timeZone.secondsFromGMT() / 60,
            channel: "ios"
        )
    }

    // MARK: - Private Properties

    private let screen: UIScreen
    private let bundle: Bundle
    private let timeZone: TimeZone
}
