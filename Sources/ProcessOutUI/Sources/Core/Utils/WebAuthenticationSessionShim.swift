//
//  WebAuthenticationSessionShim.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.06.2026.
//

@_spi(PO) import protocol ProcessOut.POWebAuthenticationSession

// TODO: Remove after upgrading to a Swift version with `::` module disambiguation.
//
// `ProcessOutUI.POWebAuthenticationSession` shadows `ProcessOut.POWebAuthenticationSession`, and
// `ProcessOut.POWebAuthenticationSession` cannot be used directly because `ProcessOut` is both the
// module name and a type exported by that module. This alias provides an unambiguous reference to
// the imported type.
typealias WebAuthenticationSessionShim = ProcessOut.POWebAuthenticationSession
