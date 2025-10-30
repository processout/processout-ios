//
//  AsnNull.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2025.
//

/// A representation of an ASN.1 NULL node.
struct AsnNull: AsnNode {

    var tagNumber: UInt8 {
        0x05
    }

    var isConstructed: Bool {
        false
    }

    func accept<V: AsnNodeVisitor>(visitor: V) -> V.Result {
        visitor.visit(null: self)
    }
}

extension AsnNode where Self == AsnNull {

    static var null: AsnNull {
        AsnNull()
    }
}
