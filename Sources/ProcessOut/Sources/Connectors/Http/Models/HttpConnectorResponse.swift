//
//  HttpConnectorResponse.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 31.03.2023.
//

import Foundation

enum HttpConnectorResponse<Value: Decodable>: Decodable {

    case success(Value), failure(HttpConnectorFailure.Server)

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if try container.decode(Bool.self, forKey: .success) {
            let value = try decoder.singleValueContainer().decode(Value.self)
            self = .success(value)
        } else {
            let failure = try decoder.singleValueContainer().decode(HttpConnectorFailure.Server.self)
            self = .failure(failure)
        }
    }

    // MARK: - Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case success
    }
}
