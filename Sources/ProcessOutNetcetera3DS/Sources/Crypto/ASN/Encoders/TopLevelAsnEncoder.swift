//
//  TopLevelAsnEncoder.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2025.
//

protocol TopLevelAsnEncoder<Output> {

    /// The type this encoder produces.
    associatedtype Output

    /// Encodes given ASN node.
    func encode(_ encodable: some AsnNode) -> Output
}
