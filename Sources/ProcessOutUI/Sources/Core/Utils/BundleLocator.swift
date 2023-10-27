//
//  BundleLocator.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 17.10.2023.
//

import Foundation

// swiftlint:disable:next convenience_type
final class BundleLocator {

    #if SWIFT_PACKAGE
    static let bundle = Bundle.module
    #else
    static let bundle = Bundle(for: BundleLocator.self)
    #endif
}
