//
//  POImageResource.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.04.2024.
//

import Foundation

/// Image resource with light/dark image variations.
public struct POImageResource: Decodable {

    public struct ResourceUrl: Decodable {

        /// Asset URLs.
        public let vector, raster: URL?
    }

    /// Image to use in light mode (on light backgrounds).
    public let lightUrl: ResourceUrl

    /// Image to use in dark mode (on dark backgrounds).
    public let darkUrl: ResourceUrl?
}
