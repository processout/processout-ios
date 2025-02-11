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
    func matches_whenCustomSchemeIsNotNormalized() {
        // Given
        let sut = POWebAuthenticationCallback.customScheme("TeSt")

        // When
        let url = URL(string: "tEsT://")!

        // Then
        #expect(sut.matches(url: url))
    }

    func matches_whenCustomSchemesAreDifferent_dontMatch() {
        // Given
        let sut = POWebAuthenticationCallback.customScheme("one")

        // When
        let url = URL(string: "two://")!

        // Then
        #expect(!sut.matches(url: url))
    }

    @Test
    @available(iOS 17.4, *)
    func matches_whenHttpsHostAndPathAreNotNormalized() {
        // Given
        let sut = POWebAuthenticationCallback.https(host: "tëst.com", path: "~path/")

        // When
        let url = URL(string: "https://xn--tst-jma.COM.//%7Epath///")!

        // Then
        #expect(sut.matches(url: url))
    }

    @Test
    @available(iOS 17.4, *)
    func matches_whenHttpsPathIsEmpty() {
        // Given
        let sut = POWebAuthenticationCallback.https(host: "test.com", path: "")

        // When
        let url = URL(string: "https://test.com///")!

        // Then
        #expect(sut.matches(url: url))
    }

    @Test
    @available(iOS 17.4, *)
    func matches_whenHttpsHostsAreDifferent_doesntMatch() {
        // Given
        let sut = POWebAuthenticationCallback.https(host: "one.com", path: "")

        // When
        let url = URL(string: "https://two.com")!

        // Then
        #expect(!sut.matches(url: url))
    }

    @Test
    @available(iOS 17.4, *)
    func matches_whenSchemeIsNotHttps_doesntMatch() {
        // Given
        let sut = POWebAuthenticationCallback.https(host: "test.com", path: "")

        // When
        let url = URL(string: "custom://test.com")!

        // Then
        #expect(!sut.matches(url: url))
    }
}
