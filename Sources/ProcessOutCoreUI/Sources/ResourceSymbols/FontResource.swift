//
//  FontResource.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 28.09.2023.
//

// swiftlint:disable strict_fileprivate

import UIKit

/// A font resource.
struct FontResource {

    /// Font resource name.
    fileprivate let name: String

    /// Font family.
    fileprivate let family: String

    /// Actual font resource name.
    fileprivate let resource: String
}

extension FontResource {

    enum WorkSans {

        /// The "WorkSans/Regular" font resource.
        static let regular = FontResource(name: "WorkSans-Regular", family: "Work Sans", resource: "WorkSans.ttf")

        /// The "WorkSans/Medium" font resource.
        static let medium = FontResource(name: "WorkSansRoman-Medium", family: "Work Sans", resource: "WorkSans.ttf")
    }

    static func register() {
        register(resource: "WorkSans.ttf")
        register(resource: "WorkSans-Italic.ttf")
    }

    // MARK: - Private

    fileprivate static func register(resource: String) {
        let bundle = BundleLocator.bundle
        guard let url = bundle.url(forResource: resource, withExtension: nil) else {
            assertionFailure("Unable to locate font resource.")
            return
        }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }
}

extension UIKit.UIFont {

    /// Initialize a `UIFont` with an font resource and size.
    convenience init(_ resource: FontResource, size: CGFloat) {
        if !UIFont.fontNames(forFamilyName: resource.family).contains(resource.name) {
            FontResource.register(resource: resource.resource)
        }
        self.init(name: resource.name, size: size)! // swiftlint:disable:this force_unwrapping
    }
}

// swiftlint:enable strict_fileprivate
