//
//  AsnDerEncoder.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2025.
//

import Foundation

struct AsnDerEncoder: TopLevelAsnEncoder, AsnNodeVisitor {

    // MARK: - TopLevelAsnEncoder

    func encode(_ encodable: some AsnNode) -> Data {
        let encodedTag = encodeTag(of: encodable)
        let encodedValue = encodable.accept(visitor: self)
        let encodedLength = encodeLength(encodedValue.count)
        return [encodedTag] + encodedLength + encodedValue
    }

    // MARK: - AsnNodeVisitor

    func visit(integer: AsnInteger) -> Data {
        var encodedValue = integer.rawValue
        while encodedValue.count > 1 && encodedValue[0] == 0x00 && encodedValue[1] < 0x80 {
            encodedValue.removeFirst()
        }
        if let mostSignificantByte = encodedValue.first, mostSignificantByte >= 0x80 {
            encodedValue.insert(0x00, at: 0)
        }
        return encodedValue
    }

    func visit(bitString: AsnBitString) -> Data {
        let encodedValue: Data = switch bitString {
        case .encapsulated(let node):
            encode(node)
        case .primitive(let data):
            data
        }
        return Data([0x00]) + encodedValue
    }

    func visit(null: AsnNull) -> Data {
        Data()
    }

    func visit(objectIdentifier: AsnObjectIdentifier) -> Data {
        guard objectIdentifier.rawValue.count >= 2 else {
            preconditionFailure("Invalid object identifier.")
        }
        var encodedValue: [UInt8] = [
            UInt8(0x28 * objectIdentifier.rawValue[0] + objectIdentifier.rawValue[1])
        ]
        for component in objectIdentifier.rawValue.dropFirst(2) {
            encodedValue.append(contentsOf: component.base128EncodedData)
        }
        return Data(encodedValue)
    }

    func visit(sequence: AsnSequence) -> Data {
        sequence.elements.map { encode($0) }.reduce(Data(), +)
    }

    // MARK: - Tag Encoding

    private func encodeTag(of node: AsnNode) -> UInt8 {
        let constructed: UInt8 = node.isConstructed ? 0x20 : 0
        return constructed | node.tagNumber // Universal class is assumed
    }

    // MARK: - Length Encoding

    private func encodeLength(_ length: Int) -> Data {
        guard length >= 0x80 else {
            return Data([UInt8(length)]) // Short form
        }
        var encodedLength: [UInt8] = []
        let lengthWidth = (length.bitWidth - length.leadingZeroBitCount + 7) / 8
        encodedLength.append(UInt8(0x80 | lengthWidth))
        encodedLength.append(contentsOf: withUnsafeBytes(of: length.bigEndian, [UInt8].init).suffix(lengthWidth))
        return Data(encodedLength)
    }
}
