//
//  UnsignedInteger+Base128EncodedData.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2025.
//

import Foundation

extension UnsignedInteger {

    /// Returns Base-128 encoded data.
    var base128EncodedData: Data {
        guard self > 0x7F else {
            return Data([UInt8(self)])
        }
        var encoded: [UInt8] = [], value = self
        while value > 0 {
            encoded.append(UInt8(value & 0x7F) | 0x80)
            value >>= 7
        }
        encoded[0] &= 0x7F // Set MSB bit to 0
        return Data(encoded.reversed())
    }
}
