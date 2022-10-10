//
//  BundleLocator.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.10.2022.
//

import Foundation

// swiftlint:disable:next convenience_type
final class BundleLocator {

    static let bundle: Bundle = {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return getResourcesBundle()
        #endif
    }()

    /// Attempts to resolve current bundle by searching following places:
    /// 1. ProcessOut.bundle (for manual static installations and framework-less Cocoapods).
    /// 2. ProcessOut.framework/ProcessOut.bundle (for framework-based Cocoapods)
    /// 3. ProcessOut.framework (manual dynamic installations)
    private static func getResourcesBundle() -> Bundle {
        let bundleName = "ProcessOut"
        if let bundle = Bundle(path: bundleName + ".bundle") {
            return bundle
        }
        if let path = Bundle(for: BundleLocator.self).path(forResource: bundleName, ofType: "bundle"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        return Bundle(for: BundleLocator.self)
    }
}
