//
//  POImageRemoteResource.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.04.2024.
//

import Foundation

/// Image resource with light/dark image variations.
public struct POImageRemoteResource: Hashable, Decodable {

    public struct ResourceUrl: Hashable, Decodable {

        /// Raster asset URLs.
        public let raster: URL

        /// Image scale. Value is hardcoded to 4.
        var scale: CGFloat { 4.0 }
    }

    /// Image to use in light mode (on light backgrounds).
    public let lightUrl: ResourceUrl

    /// Image to use in dark mode (on dark backgrounds).
    public let darkUrl: ResourceUrl?
}
