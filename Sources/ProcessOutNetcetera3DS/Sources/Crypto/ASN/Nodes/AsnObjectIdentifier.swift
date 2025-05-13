//
//  AsnObjectIdentifier.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2025.
//

/// A representation of an ASN.1 OBJECT IDENTIFIER node.
struct AsnObjectIdentifier: RawRepresentable, AsnNode {

    let rawValue: [UInt]

    init(rawValue: [UInt]) {
        self.rawValue = rawValue
    }

    init(rawValue: UInt...) {
        self.rawValue = rawValue
    }

    // MARK: - AsnNode

    var tagNumber: UInt8 {
        0x06
    }

    var isConstructed: Bool {
        false
    }

    func accept<V: AsnNodeVisitor>(visitor: V) -> V.Result {
        visitor.visit(objectIdentifier: self)
    }
}

extension AsnObjectIdentifier {

    // MARK: - Elliptic Curve

    /// Elliptic curve.
    static let ecPublicKey = Self(rawValue: 1, 2, 840, 10045, 2, 1)

    /// 192-bit curve.
    static let prime192v1 = Self(rawValue: 1, 2, 840, 10045, 3, 1, 1)

    /// 256-bit curve.
    static let prime256v1 = Self(rawValue: 1, 2, 840, 10045, 3, 1, 7)

    /// 384-bit curve.
    static let ansip384r1 = Self(rawValue: 1, 3, 132, 0, 34)

    /// 521-bit curve.
    static let ansip521r1 = Self(rawValue: 1, 3, 132, 0, 35)

    // MARK: - RSA

    /// RSAES-PKCS1-v1_5 encryption scheme.
    static let rsaEncryption = Self(rawValue: 1, 2, 840, 113549, 1, 1, 1)
}
