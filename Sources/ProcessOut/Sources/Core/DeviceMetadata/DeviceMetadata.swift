//
//  RequestHelpers.swift
//  ProcessOut
//
//  Created by Simeon Kostadinov on 28/10/2022.
//

import Foundation

struct DeviceMetadata: Encodable {

    /// Current device identifier.
    @POImmutableExcludedCodable
    var id: String?

    /// Installation identifier. Value changes if host application is reinstalled.
    @POImmutableExcludedCodable
    var installationId: String?

    /// Device system version.
    @POImmutableExcludedCodable
    var systemVersion: String

    /// Device model.
    @POImmutableExcludedCodable
    var model: String?

    /// Default app language.
    let appLanguage: String

    /// Width of the screen in pixels.
    let appScreenWidth: Int

    /// Height of the screen in pixles.
    let appScreenHeight: Int

    /// Time zone offset in minutes.
    let appTimeZoneOffset: Int

    /// Device channel. Holds device system name.
    let channel: String
}
