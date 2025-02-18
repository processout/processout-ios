//
//  POImageRemoteResource.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.04.2024.
//

import Foundation

/// Image resource with light/dark image variations.
public struct POImageRemoteResource: Hashable, Decodable, Sendable {

    public struct ResourceUrl: Hashable, Sendable {

        /// Raster asset URLs.
        public let raster: URL

        /// Image scale. Value is hardcoded to 4.
        public var scale: CGFloat
    }

    /// Image to use in light mode (on light backgrounds).
    public let lightUrl: ResourceUrl

    /// Image to use in dark mode (on dark backgrounds).
    public let darkUrl: ResourceUrl?
}

extension POImageRemoteResource.ResourceUrl: Decodable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        raster = try container.decode(URL.self, forKey: .raster)
        scale = 4
    }

    // MARK: - Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case raster
    }
}
