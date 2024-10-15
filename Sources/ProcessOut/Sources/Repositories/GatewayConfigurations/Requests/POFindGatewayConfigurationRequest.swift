//
//  POFindGatewayConfigurationRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.10.2022.
//

import Foundation

public struct POFindGatewayConfigurationRequest: Sendable {

    public enum ExpandedProperty: String, Hashable, Sendable {
        case gateway
    }

    /// Configuration identifier.
    public let id: String

    /// Configuration properties that should be expanded in a response.
    public let expand: Set<ExpandedProperty>

    public init(id: String, expands: ExpandedProperty...) {
        self.id = id
        self.expand = Set(expands)
    }
}
