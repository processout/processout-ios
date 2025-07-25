//
//  ImageResource.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 31.07.2024.
//

import SwiftUI

// swiftlint:disable strict_fileprivate

/// An image resource.
@_spi(PO)
public struct POImageResource: Hashable, Sendable {

    init(name: String) {
        self.name = name
        self.bundle = BundleLocator.bundle
    }

    public init(name: String, bundle: Bundle) {
        self.name = name
        self.bundle = bundle
    }

    /// An asset catalog image resource name.
    fileprivate let name: String

    /// An asset catalog image resource bundle.
    fileprivate let bundle: Bundle
}

extension POImageResource {

    /// The "Info" asset catalog image resource.
    public static let info = POImageResource(name: "Info")

    /// The "Info" asset catalog image resource.
    public static let chevronDown = POImageResource(name: "ChevronDown")

    /// The "DocumentOnDocument" asset catalog image resource.
    public static let docOnDoc = POImageResource(name: "DocumentOnDocument")

    /// The "Check" asset catalog image resource.
    public static let check = POImageResource(name: "Check")
}

extension Image {

    /// Initialize an `Image` with an image resource.
    @_spi(PO)
    public init(poResource resource: POImageResource) {
        self.init(resource.name, bundle: resource.bundle)
    }
}

extension UIImage {

    /// Initialize an `Image` with an image resource.
    @_spi(PO)
    public convenience init(poResource resource: POImageResource) {
        // swiftlint:disable:next force_unwrapping
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
    }
}

// swiftlint:enable strict_fileprivate
