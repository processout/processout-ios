//
//  POFindGatewayConfigurationRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.10.2022.
//

import Foundation

public struct POFindGatewayConfigurationRequest {

    public enum ExpandedProperty: String, Hashable {
        case gateway
    }

    /// Configuration identifier.
    public let id: String

    /// Configuration properties that should be expanded in a response.
    public let expands: Set<ExpandedProperty>

    public init(id: String, expands: ExpandedProperty...) {
        self.id = id
        self.expands = Set(expands)
    }
}
