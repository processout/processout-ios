//
//  RequestHelpers.swift
//  ProcessOut
//
//  Created by Simeon Kostadinov on 28/10/2022.
//

import Foundation

struct DeviceMetadata: Encodable, Sendable {

    /// Current device identifier.
    let id: String?

    /// Installation identifier. Value changes if host application is reinstalled.
    @POExcludedEncodable
    private(set) var installationId: String?

    /// Device system version.
    @POExcludedEncodable
    private(set) var systemVersion: String

    /// Device model.
    @POExcludedEncodable
    private(set) var model: String?

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
