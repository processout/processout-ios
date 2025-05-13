//
//  AsnNode.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2025.
//

/// A node representing an ASN.1 element.
protocol AsnNode {

    /// The ASN.1 tag number representing the type of this node.
    var tagNumber: UInt8 { get }

    /// A flag indicating whether the node is a constructed type.
    var isConstructed: Bool { get }

    /// Accepts a visitor that can perform operations based on the concrete node type.
    /// - Returns: The result of the visitor's operation.
    func accept<V: AsnNodeVisitor>(visitor: V) -> V.Result
}
