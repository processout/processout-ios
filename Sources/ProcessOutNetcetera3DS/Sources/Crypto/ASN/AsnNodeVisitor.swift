//
//  AsnNodeVisitor.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2025.
//

/// A visitor protocol for traversing or processing ASN.1 nodes.
protocol AsnNodeVisitor {

    /// The type of result returned by the visitor methods.
    associatedtype Result

    /// Visits an ASN.1 INTEGER node.
    func visit(integer: AsnInteger) -> Result

    /// Visits an ASN.1 BIT STRING node.
    func visit(bitString: AsnBitString) -> Result

    /// Visits an ASN.1 NULL node.
    func visit(null: AsnNull) -> Result

    /// Visits an ASN.1 OBJECT IDENTIFIER node.
    func visit(objectIdentifier: AsnObjectIdentifier) -> Result

    /// Visits an ASN.1 SEQUENCE node.
    func visit(sequence: AsnSequence) -> Result
}
