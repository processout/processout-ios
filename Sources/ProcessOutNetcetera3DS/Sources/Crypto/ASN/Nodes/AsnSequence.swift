//
//  AsnSequence.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2025.
//

/// A representation of an ASN.1 SEQUENCE node.
struct AsnSequence: AsnNode {

    let elements: [AsnNode]

    // MARK: - AsnNode

    var tagNumber: UInt8 {
        0x10
    }

    var isConstructed: Bool {
        true
    }

    func accept<V: AsnNodeVisitor>(visitor: V) -> V.Result {
        visitor.visit(sequence: self)
    }
}

extension AsnNode where Self == AsnSequence {

    static func sequence(_ elements: AsnNode...) -> AsnSequence {
        AsnSequence(elements: elements)
    }
}
