//
//  HttpConnectorResponse.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 23.07.2024.
//

struct HttpConnectorResponse<Value: Sendable>: Sendable {

    /// Value.
    let value: Value

    /// Response headers.
    let headers: [String: String]
}
