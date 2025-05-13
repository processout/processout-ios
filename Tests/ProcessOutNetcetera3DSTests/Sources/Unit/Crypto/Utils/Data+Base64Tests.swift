//
//  Data+Base64Tests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 30.04.2025.
//

import Foundation
import Testing
@testable import ProcessOutNetcetera3DS

struct DataBase64UrlEncodingTests {

    @Test(arguments: ["VGVzdA", "VGVzdA=", "VGVzdA=="])
    func whenTwoPaddingCharactersAreExpected_succeeds(base64UrlEncoded: String) {
        let data = Data(base64UrlEncoded: base64UrlEncoded)
        #expect(data == Data("Test".utf8))
    }

    @Test(arguments: ["VGVzdCE", "VGVzdCE="])
    func whenPaddingCharacterIsExpected_succeeds(base64UrlEncoded: String) {
        let data = Data(base64UrlEncoded: base64UrlEncoded)
        #expect(data == Data("Test!".utf8))
    }

    @Test
    func whenValueIsValid() {
        let base64UrlEncoded = "VGVzdCEh"
        let data = Data(base64UrlEncoded: base64UrlEncoded)
        #expect(data == Data("Test!!".utf8))
    }

    @Test
    func whenValueIsEmpty_createsEmptyData() {
        let data = Data(base64UrlEncoded: "")
        #expect(data == Data())
    }

    @Test
    func whenValueHasInvalidCharacters_returnNil() {
        let base64UrlEncoded = "VA==*"
        let data = Data(base64UrlEncoded: base64UrlEncoded)
        #expect(data == nil)
    }

    @Test
    func whenValueHasUrlUnsafeCharacters_succeeds() {
        let base64UrlEncoded = "+-/_"
        let data = Data(base64UrlEncoded: base64UrlEncoded)
        #expect(data == Data([0xFB, 0xEF, 0xFF]))
    }
}
