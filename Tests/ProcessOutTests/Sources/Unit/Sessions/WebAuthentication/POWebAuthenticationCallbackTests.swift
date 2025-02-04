//
//  POWebAuthenticationCallbackTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.02.2025.
//

import Foundation
import Testing
@testable @_spi(PO) import ProcessOut

struct POWebAuthenticationCallbackTests {

    @Test
    func matches_whenSchemeIsNotNormalized() {
        // Given
        let sut = POWebAuthenticationCallback.customScheme("TeSt")

        // When
        let url = URL(string: "tEsT://")!

        // Then
        #expect(sut.matches(url: url))
    }

    @Test
    @available(iOS 17.4, *)
    func matches_whenHostAndPathAreNotNormalized() {
        // Given
        let sut = POWebAuthenticationCallback.https(host: "tëst.com", path: "path/")

        // When
        let url = URL(string: "https://xn--tst-jma.COM.//path///")!

        // Then
        #expect(sut.matches(url: url))
    }
}
