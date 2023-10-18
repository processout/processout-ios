//
//  ColorResource.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 11.10.2023.
//

import UIKit

// swiftlint:disable strict_fileprivate identifier_name

/// A color resource.
/// - NOTE: This type wraps natively generated `ColorResource` to make resources publicly accessible.
@_spi(PO) public struct POColorResource {

    fileprivate init(_ colorResource: ColorResource) {
        self.colorResource = colorResource
    }

    fileprivate let colorResource: ColorResource
}

extension POColorResource {

    /// The "Surface" asset catalog resource namespace.
    public enum Surface {

        /// The "Surface/Background" asset catalog color resource.
        public static let background = POColorResource(.Surface.background)

        /// The "Surface/Error" asset catalog color resource.
        public static let error = POColorResource(.Surface.error)

        /// The "Surface/Level1" asset catalog color resource.
        public static let level1 = POColorResource(.Surface.level1)

        /// The "Surface/Neutral" asset catalog color resource.
        public static let neutral = POColorResource(.Surface.neutral)

        /// The "Surface/Success" asset catalog color resource.
        public static let success = POColorResource(.Surface.success)

        /// The "Surface/Warning" asset catalog color resource.
        public static let warning = POColorResource(.Surface.warning)
    }

    /// The "Text" asset catalog resource namespace.
    public enum Text {

        /// The "Text/Disabled" asset catalog color resource.
        public static let disabled = POColorResource(.Text.disabled)

        /// The "Text/Error" asset catalog color resource.
        public static let error = POColorResource(.Text.error)

        /// The "Text/Muted" asset catalog color resource.
        public static let muted = POColorResource(.Text.muted)

        /// The "Text/OnColor" asset catalog color resource.
        public static let on = POColorResource(.Text.on)

        /// The "Text/Primary" asset catalog color resource.
        public static let primary = POColorResource(.Text.primary)

        /// The "Text/Secondary" asset catalog color resource.
        public static let secondary = POColorResource(.Text.secondary)

        /// The "Text/Success" asset catalog color resource.
        public static let success = POColorResource(.Text.success)

        /// The "Text/Tertiary" asset catalog color resource.
        public static let tertiary = POColorResource(.Text.tertiary)

        /// The "Text/Warning" asset catalog color resource.
        public static let warning = POColorResource(.Text.warning)
    }
}

extension UIKit.UIColor {

    /// Initialize a `UIColor` with a color resource.
    @_spi(PO) public convenience init(poResource: POColorResource) {
        self.init(resource: poResource.colorResource)
    }
}

// swiftlint:enable strict_fileprivate identifier_name
