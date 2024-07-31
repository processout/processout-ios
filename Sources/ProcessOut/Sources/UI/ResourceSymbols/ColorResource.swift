//
//  ColorResource.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 11.10.2023.
//

import SwiftUI

// swiftlint:disable strict_fileprivate nesting

/// A color resource.
/// - NOTE: Type is prefixed with PO but not public to disambiguate from native `ColorResource`.
struct POColorResource: Hashable, Sendable {

    init(name: String) {
        self.name = name
        self.bundle = BundleLocator.bundle
    }

    /// Resource name.
    fileprivate let name: String

    /// Resource bundle.
    fileprivate let bundle: Bundle
}

extension POColorResource {

    /// The "Surface" asset catalog resource namespace.
    enum Surface {

        /// The "Surface/Background" asset catalog color resource.
        static let background = POColorResource(name: "Surface/Background")

        /// The "Surface/Error" asset catalog color resource.
        static let error = POColorResource(name: "Surface/Error")

        /// The "Surface/Level1" asset catalog color resource.
        static let level1 = POColorResource(name: "Surface/Level1")

        /// The "Surface/Neutral" asset catalog color resource.
        static let neutral = POColorResource(name: "Surface/Neutral")

        /// The "Surface/Success" asset catalog color resource.
        static let success = POColorResource(name: "Surface/Success")

        /// The "Surface/Warning" asset catalog color resource.
        static let warning = POColorResource(name: "Surface/Warning")
    }

    /// The "Action" asset catalog resource namespace.
    enum Action {

        /// The "Action/Primary" asset catalog resource namespace.
        enum Primary {

            /// The "Action/Primary/Default" asset catalog color resource.
            static let `default` = POColorResource(name: "Action/Primary/Default")

            /// The "Action/Primary/Disabled" asset catalog color resource.
            static let disabled = POColorResource(name: "Action/Primary/Disabled")

            /// The "Action/Primary/Pressed" asset catalog color resource.
            static let pressed = POColorResource(name: "Action/Primary/Pressed")
        }

        /// The "Action/Secondary" asset catalog resource namespace.
        enum Secondary {

            /// The "Action/Secondary/Default" asset catalog color resource.
            static let `default` = POColorResource(name: "Action/Secondary/Default")

            /// The "Action/Secondary/Pressed" asset catalog color resource.
            static let pressed = POColorResource(name: "Action/Secondary/Pressed")
        }

        /// The "Action/Border" asset catalog resource namespace.
        enum Border {

            /// The "Action/Border/Disabled" asset catalog color resource.
            static let disabled = POColorResource(name: "Action/Border/Disabled")

            /// The "Action/Border/Selected" asset catalog color resource.
            static let selected = POColorResource(name: "Action/Border/Selected")
        }
    }

    /// The "Border" asset catalog resource namespace.
    enum Border {

        /// The "Border/Default" asset catalog color resource.
        static let `default` = POColorResource(name: "Border/Default")

        /// The "Border/Divider" asset catalog color resource.
        static let divider = POColorResource(name: "Border/Divider")

        /// The "Border/Subtle" asset catalog color resource.
        static let subtle = POColorResource(name: "Border/Subtle")
    }

    /// The "Text" asset catalog resource namespace.
    enum Text {

        /// The "Text/Disabled" asset catalog color resource.
        static let disabled = POColorResource(name: "Text/Disabled")

        /// The "Text/Error" asset catalog color resource.
        static let error = POColorResource(name: "Text/Error")

        /// The "Text/Muted" asset catalog color resource.
        static let muted = POColorResource(name: "Text/Muted")

        /// The "Text/OnColor" asset catalog color resource.
        static let on = POColorResource(name: "Text/OnColor") // swiftlint:disable:this identifier_name

        /// The "Text/Primary" asset catalog color resource.
        static let primary = POColorResource(name: "Text/Primary")

        /// The "Text/Secondary" asset catalog color resource.
        static let secondary = POColorResource(name: "Text/Secondary")

        /// The "Text/Success" asset catalog color resource.
        static let success = POColorResource(name: "Text/Success")

        /// The "Text/Tertiary" asset catalog color resource.
        static let tertiary = POColorResource(name: "Text/Tertiary")

        /// The "Text/Warning" asset catalog color resource.
        static let warning = POColorResource(name: "Text/Warning")
    }
}

extension UIColor {

    /// Initialize an `Image` with an image resource.
    convenience init(resource: POColorResource) {
        // swiftlint:disable:next force_unwrapping
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
    }
}

// swiftlint:enable strict_fileprivate nesting
