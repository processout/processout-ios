//
//  ColorResource.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 11.10.2023.
//

import SwiftUI

// swiftlint:disable strict_fileprivate

/// A color resource.
/// - NOTE: This type wraps natively generated `ColorResource` to make resources publicly accessible.
@_spi(PO) public struct POColorResource {

    fileprivate init(_ colorResource: ColorResource) {
        self.colorResource = colorResource
    }

    fileprivate let colorResource: ColorResource
}

extension POColorResource {

    /// The "Border" asset catalog resource namespace.
    public enum Border {

        /// The "Border/Subtle" asset catalog color resource.
        public static let subtle = POColorResource(.Border.subtle)
    }

    /// The "Surface" asset catalog resource namespace.
    public enum Surface {

        /// The "Surface/Default" asset catalog color resource.
        public static let `default` = POColorResource(.Surface.default)

        /// The "Surface/Neutral" asset catalog color resource.
        public static let neutral = POColorResource(.Surface.neutral)

        /// The "Surface/Success" asset catalog color resource.
        public static let success = POColorResource(.Surface.success)

        /// The "Surface/Error" asset catalog color resource.
        public static let error = POColorResource(.Surface.error)
    }

    /// The "Text" asset catalog resource namespace.
    public enum Text {

        /// The "Text/Disabled" asset catalog color resource.
        public static let disabled = POColorResource(.Text.disabled)

        /// The "Text/Error" asset catalog color resource.
        public static let error = POColorResource(.Text.error)

        /// The "Text/Muted" asset catalog color resource.
        public static let muted = POColorResource(.Text.muted)

        /// The "Text/Inverse" asset catalog color resource.
        public static let inverse = POColorResource(.Text.inverse)

        /// The "Text/Primary" asset catalog color resource.
        public static let primary = POColorResource(.Text.primary)

        /// The "Text/Success" asset catalog color resource.
        public static let success = POColorResource(.Text.success)
    }
}

extension SwiftUI.Color {

    /// Initialize a `Color` with a color resource.
    @_spi(PO) public init(poResource: POColorResource) {
        self.init(poResource.colorResource)
    }
}

// swiftlint:enable strict_fileprivate
