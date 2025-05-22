//
//  TopLevelJwkEncoder.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2025.
//

protocol TopLevelJwkEncoder<Output> {

    /// The type this encoder produces.
    associatedtype Output

    /// Encodes given ASN node.
    func encode(_ encodable: Jwk) throws(JwkEncodingError) -> Output
}
