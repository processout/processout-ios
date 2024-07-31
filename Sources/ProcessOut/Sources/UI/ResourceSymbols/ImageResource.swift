//
//  ImageResource.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 31.07.2024.
//

import SwiftUI

// swiftlint:disable strict_fileprivate

/// An image resource.
/// - NOTE: Type is prefixed with PO but not public to disambiguate from native `POImageResource`.
struct POImageResource: Hashable, Sendable {

    init(name: String) {
        self.name = name
        self.bundle = BundleLocator.bundle
    }

    /// An asset catalog image resource name.
    fileprivate let name: String

    /// An asset catalog image resource bundle.
    fileprivate let bundle: Bundle
}

extension POImageResource {

    /// The "ChevronDown" asset catalog image resource.
    static let chevronDown = POImageResource(name: "ChevronDown")

    /// The "Success" asset catalog image resource.
    static let success = POImageResource(name: "Success")
}

extension UIImage {

    /// Initialize an `Image` with an image resource.
    convenience init(poResource resource: POImageResource) {
        // swiftlint:disable:next force_unwrapping
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
    }
}

// swiftlint:enable strict_fileprivate
