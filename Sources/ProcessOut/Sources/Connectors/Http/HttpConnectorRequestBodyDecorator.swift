//
//  HttpConnectorRequestBodyDecorator.swift
//  ProcessOut
//
//  Created by Simeon Kostadinov on 31/10/2022.
//

import Foundation

struct HttpConnectorRequestBodyDecorator: Encodable {

    /// Primary request body.
    let body: POAnyEncodable

    /// Device metadata.
    let deviceMetadata: DeviceMetadata

    func encode(to encoder: Encoder) throws {
        try body.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(deviceMetadata, forKey: .device)
    }

    // MARK: - Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case device
    }
}
