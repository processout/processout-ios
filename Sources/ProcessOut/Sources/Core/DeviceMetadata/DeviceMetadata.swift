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

    /// Difference in minutes between UTC and device local time (UTC - local), e.g. -60 for UTC+1.
    /// Follows JavaScript `Date.getTimezoneOffset()` and EMVCo browser time zone semantics.
    let appTimezoneOffset: Int

    /// Device channel. Holds device system name. Legacy field, backend uses it for 3DS SDK
    /// selection when `threedsSdk` is not set. Kept for backward compatibility.
    let channel: String

    /// Type of the 3DS SDK that is (or is expected to be) used to authenticate payments.
    let threedsSdk: String

    /// Platform of the device, used by backend for analytics and reporting.
    let platform: String
}
