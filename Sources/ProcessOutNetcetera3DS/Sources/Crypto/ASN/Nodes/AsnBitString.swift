//
//  AsnBitString.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2025.
//

import Foundation

/// A representation of an ASN.1 BIT STRING node.
enum AsnBitString: AsnNode {

    /// An encapsulated BIT STRING wrapping another ASN.1 node.
    case encapsulated(AsnNode)

    /// A primitive BIT STRING with raw bit data.
    case primitive(Data)

    // MARK: - AsnNode

    var tagNumber: UInt8 {
        0x03
    }

    var isConstructed: Bool {
        false
    }

    func accept<V: AsnNodeVisitor>(visitor: V) -> V.Result {
        visitor.visit(bitString: self)
    }
}

extension AsnNode where Self == AsnBitString {

    static func bitString(encapsulating element: AsnNode) -> some AsnNode {
        AsnBitString.encapsulated(element)
    }

    static func bitString(bits data: Data) -> some AsnNode {
        AsnBitString.primitive(data)
    }
}
