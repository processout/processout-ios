//
//  RequestHelpers.swift
//  ProcessOut
//
//  Created by Simeon Kostadinov on 28/10/2022.
//

import Foundation

struct DeviceMetadata: Encodable, Sendable { // sourcery: AutoCodingKeys

    /// Current device identifier.
    let id: String? // sourcery:coding: skip

    /// Installation identifier. Value changes if host application is reinstalled.
    let installationId: String? // sourcery:coding: skip

    /// Device system version.
    let systemVersion: String // sourcery:coding: skip

    /// Device model.
    let model: String? // sourcery:coding: skip

    /// Default app language.
    let appLanguage: String

    /// Width of the screen in pixels.
    let appScreenWidth: Int

    /// Height of the screen in pixels.
    let appScreenHeight: Int

    /// Time zone offset in minutes.
    let appTimeZoneOffset: Int

    /// Device channel. Holds device system name.
    let channel: String
}
