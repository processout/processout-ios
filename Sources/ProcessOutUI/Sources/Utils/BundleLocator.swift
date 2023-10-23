//
//  BundleLocator.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 17.10.2023.
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
    /// 1. ProcessOutUI.bundle (for manual static installations and framework-less Cocoapods).
    /// 2. ProcessOutUI.framework/ProcessOut.bundle (for framework-based Cocoapods)
    /// 3. ProcessOutUI.framework (manual dynamic installations)
    private static func getResourcesBundle() -> Bundle {
        let bundleName = "ProcessOutUI"
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
