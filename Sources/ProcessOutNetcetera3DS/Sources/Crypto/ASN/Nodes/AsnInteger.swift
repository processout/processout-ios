//
//  AsnInteger.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2025.
//

import Foundation

/// A representation of an ASN.1 INTEGER node.
struct AsnInteger: AsnNode {

    let rawValue: Data

    // MARK: - AsnNode

    var tagNumber: UInt8 {
        0x02
    }

    var isConstructed: Bool {
        false
    }

    func accept<V: AsnNodeVisitor>(visitor: V) -> V.Result {
        visitor.visit(integer: self)
    }
}

extension AsnNode where Self == AsnInteger {

    static func integer(_ rawValue: Data) -> AsnInteger {
        AsnInteger(rawValue: rawValue)
    }
}
