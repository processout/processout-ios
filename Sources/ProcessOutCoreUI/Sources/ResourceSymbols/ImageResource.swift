//
//  ImageResource.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 31.07.2024.
//

import SwiftUI

// swiftlint:disable strict_fileprivate

/// A color resource.
@_spi(PO)
public struct POImageResource: Hashable, Sendable {

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

    /// The "Info" asset catalog image resource.
    public static let info = POImageResource(name: "Info")
}

extension Image {

    /// Initialize an `Image` with an image resource.
    @_spi(PO)
    public init(poResource resource: POImageResource) {
        self.init(resource.name, bundle: resource.bundle)
    }
}

// swiftlint:enable strict_fileprivate
