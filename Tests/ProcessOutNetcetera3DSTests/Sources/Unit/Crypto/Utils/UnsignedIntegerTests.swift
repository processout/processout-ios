//
//  UnsignedIntegerTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 30.04.2025.
//

import Foundation
import Testing
@testable import ProcessOutNetcetera3DS

struct UnsignedIntegerToBase128EncodedDataTests {

    @Test
    func whenValueIsSmall_succeeds() {
        // Test for values that fit within 7 bits (single byte)
        let value: UInt8 = 0x7F
        let encodedData = value.base128EncodedData
        #expect(encodedData == Data([0x7F]))
    }

    @Test
    func whenValueIsLarge_succeeds() {
        let value: UInt16 = 0x80
        let encodedData = value.base128EncodedData
        #expect(encodedData == Data([0x81, 0x00]))
    }

    @Test
    func whenValueExceedsUInt8Max_succeeds() {
        // Test for a value that is larger than 8-bit max
        let value: UInt32 = 0x100
        let encodedData = value.base128EncodedData
        #expect(encodedData == Data([0x82, 0x00]))
    }

    @Test
    func whenValueIsZero_succeeds() {
        let value: UInt8 = 0x00
        let encodedData = value.base128EncodedData
        #expect(encodedData == Data([0x00]))
    }
}
