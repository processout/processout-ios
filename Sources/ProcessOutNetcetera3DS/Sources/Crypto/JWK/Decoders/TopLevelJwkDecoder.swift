//
//  TopLevelJwkDecoder.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2025.
//

protocol TopLevelJwkDecoder<Input> {

    /// The type this decoder accepts.
    associatedtype Input

    /// Decodes an instance of the indicated type.
    func decode(from: Self.Input) throws(JwkDecodingError) -> Jwk
}
