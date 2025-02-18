//
//  FontResource.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 28.09.2023.
//

// swiftlint:disable strict_fileprivate

import UIKit

/// A font resource.
struct FontResource: Sendable {

    /// Font resource name.
    fileprivate let weight: UIFont.Weight

    /// Font family.
    fileprivate let family: String

    /// Actual font resource name.
    fileprivate let resource: String
}

extension FontResource {

    static func workSans(withWeight weight: UIFont.Weight) -> FontResource {
        .init(weight: weight, family: "Work Sans", resource: "WorkSans.ttf")
    }

    static func register() {
        let registeredFontNames = Set(
            UIFont.fontNames(forFamilyName: "Work Sans")
        )
        let expectedRomanFontNames: Set<String> = [
            "WorkSans-Regular",
            "WorkSansRoman-Thin",
            "WorkSansRoman-ExtraLight",
            "WorkSansRoman-Light",
            "WorkSansRoman-Medium",
            "WorkSansRoman-SemiBold",
            "WorkSansRoman-Bold",
            "WorkSansRoman-ExtraBold",
            "WorkSansRoman-Black"
        ]
        if !registeredFontNames.isSuperset(of: expectedRomanFontNames) {
            register(resource: "WorkSans.ttf")
        }
        let expectedItalicFontNames: Set<String> = [
            "WorkSans-Italic",
            "WorkSansItalic-Thin",
            "WorkSansItalic-ExtraLight",
            "WorkSansItalic-Light",
            "WorkSansItalic-Medium",
            "WorkSansItalic-SemiBold",
            "WorkSansItalic-Bold",
            "WorkSansItalic-ExtraBold",
            "WorkSansItalic-Black"
        ]
        if !registeredFontNames.isSuperset(of: expectedItalicFontNames) {
            register(resource: "WorkSans-Italic.ttf")
        }
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
        if UIFont.fontNames(forFamilyName: resource.family).isEmpty {
            FontResource.register(resource: resource.resource)
        }
        let attributes: [UIFontDescriptor.AttributeName: Any] = [
            .family: resource.family, .traits: [UIFontDescriptor.TraitKey.weight: resource.weight]
        ]
        let descriptor = UIFontDescriptor(fontAttributes: attributes)
        self.init(descriptor: descriptor, size: size)
    }
}

// swiftlint:enable strict_fileprivate
