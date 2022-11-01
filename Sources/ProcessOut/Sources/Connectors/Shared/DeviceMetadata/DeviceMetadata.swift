//
//  RequestHelpers.swift
//  ProcessOut
//
//  Created by Simeon Kostadinov on 28/10/2022.
//

import Foundation

struct DeviceMetadata: Encodable {

    /// Default app language.
    let appLanguage: String

    /// Width of the screen in pixels.
    let appScreenWidth: Int

    /// Height of the screen in pixles.
    let appScreenHeight: Int

    /// Time zone offset in minutes.
    let appTimeZoneOffset: Int
}
