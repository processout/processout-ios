//
//  ColorResource.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 11.10.2023.
//

import SwiftUI

// swiftlint:disable strict_fileprivate nesting

/// A color resource.
@_spi(PO)
public struct POColorResource: Hashable, Sendable {

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

    /// The "Border" asset catalog resource namespace.
    public enum Border {

        /// The "Border/Subtle" asset catalog color resource.
        public static let subtle = POColorResource(name: "Border/Subtle")
    }

    /// The "Button" asset catalog resource namespace.
    public enum Button {

        /// The "Button/Primary" asset catalog resource namespace.
        public enum Primary {

            /// The "Button/Primary/Background" asset catalog resource namespace.
            public enum Background {

                /// The "Button/Primary/Background/Default" asset catalog color resource.
                public static let `default` = POColorResource(name: "Button/Primary/Background/Default")

                /// The "Button/Primary/Background/Disabled" asset catalog color resource.
                public static let disabled = POColorResource(name: "Button/Primary/Background/Disabled")

                /// The "Button/Primary/Background/Pressed" asset catalog color resource.
                public static let pressed = POColorResource(name: "Button/Primary/Background/Pressed")
            }
        }

        /// The "Button/Secondary" asset catalog resource namespace.
        public enum Secondary {

            /// The "Button/Secondary/Background" asset catalog resource namespace.
            public enum Background {

                /// The "Button/Secondary/Background/Default" asset catalog color resource.
                public static let `default` = POColorResource(name: "Button/Secondary/Background/Default")

                /// The "Button/Secondary/Background/Disabled" asset catalog color resource.
                public static let disabled = POColorResource(name: "Button/Secondary/Background/Disabled")

                /// The "Button/Secondary/Background/Pressed" asset catalog color resource.
                public static let pressed = POColorResource(name: "Button/Secondary/Background/Pressed")
            }

            /// The "Button/Secondary/Border" asset catalog resource namespace.
            public enum Border {

                /// The "Button/Secondary/Border/Default" asset catalog color resource.
                public static let `default` = POColorResource(name: "Button/Secondary/Border/Default")

                /// The "Button/Secondary/Border/Disabled" asset catalog color resource.
                public static let disabled = POColorResource(name: "Button/Secondary/Border/Disabled")

                /// The "Button/Secondary/Border/Selected" asset catalog color resource.
                public static let selected = POColorResource(name: "Button/Secondary/Border/Selected")
            }
        }

        /// The "Button/Ghost" asset catalog resource namespace.
        public enum Ghost {

            /// The "Button/Ghost/Background" asset catalog resource namespace.
            public enum Background {

                /// The "Button/Ghost/Background/Disabled" asset catalog color resource.
                public static let disabled = POColorResource(name: "Button/Ghost/Background/Disabled")

                /// The "Button/Ghost/Background/Pressed" asset catalog color resource.
                public static let pressed = POColorResource(name: "Button/Ghost/Background/Pressed")

                /// The "Button/Ghost/Background/Selected" asset catalog color resource.
                public static let selected = POColorResource(name: "Button/Ghost/Background/Selected")
            }

            /// The "Button/Ghost/Title" asset catalog resource namespace.
            public enum Title {

                /// The "Button/Ghost/Title/Default" asset catalog color resource.
                public static let `default` = POColorResource(name: "Button/Ghost/Title/Default")

                /// The "Button/Ghost/Title/Disabled" asset catalog color resource.
                public static let disabled = POColorResource(name: "Button/Ghost/Title/Disabled")

                /// The "Button/Ghost/Title/Pressed" asset catalog color resource.
                public static let pressed = POColorResource(name: "Button/Ghost/Title/Pressed")
            }
        }
    }

    /// The "Input" asset catalog resource namespace.
    public enum Input {

        /// The "Input/Background" asset catalog resource namespace.
        public enum Background {

            /// The "Input/Background/Default" asset catalog color resource.
            public static let `default` = POColorResource(name: "Input/Background/Default")

            /// The "Input/Background/Disabled" asset catalog color resource.
            public static let disabled = POColorResource(name: "Input/Background/Disabled")
        }

        /// The "Input/Border" asset catalog resource namespace.
        public enum Border {

            /// The "Input/Border/Default" asset catalog color resource.
            public static let `default` = POColorResource(name: "Input/Border/Default")

            /// The "Input/Border/Disabled" asset catalog color resource.
            public static let disabled = POColorResource(name: "Input/Border/Disabled")

            /// The "Input/Border/Error" asset catalog color resource.
            public static let error = POColorResource(name: "Input/Border/Error")

            /// The "Input/Border/Focused" asset catalog color resource.
            public static let focused = POColorResource(name: "Input/Border/Focused")

            /// The "Input/Border/Hover" asset catalog color resource.
            public static let hover = POColorResource(name: "Input/Border/Hover")
        }
    }

    /// The "Surface" asset catalog resource namespace.
    public enum Surface {

        /// The "Surface/Default" asset catalog color resource.
        public static let `default` = POColorResource(name: "Surface/Default")

        /// The "Surface/Success" asset catalog color resource.
        public static let success = POColorResource(name: "Surface/Success")

        /// The "Surface/Error" asset catalog color resource.
        public static let error = POColorResource(name: "Surface/Error")
    }

    /// The "Text" asset catalog resource namespace.
    public enum Text {

        /// The "Text/Disabled" asset catalog color resource.
        public static let disabled = POColorResource(name: "Text/Disabled")

        /// The "Text/Error" asset catalog color resource.
        public static let error = POColorResource(name: "Text/Error")

        /// The "Text/Muted" asset catalog color resource.
        public static let muted = POColorResource(name: "Text/Muted")

        /// The "Text/Inverse" asset catalog color resource.
        public static let inverse = POColorResource(name: "Text/Inverse")

        /// The "Text/Primary" asset catalog color resource.
        public static let primary = POColorResource(name: "Text/Primary")

        /// The "Text/Success" asset catalog color resource.
        public static let success = POColorResource(name: "Text/Success")
    }
}

extension SwiftUI.Color {

    /// Initialize a `Color` with a color resource.
    @_spi(PO)
    public init(poResource resource: POColorResource) {
        self.init(resource.name, bundle: resource.bundle)
    }
}

extension UIColor {

    /// Initialize an `Image` with an image resource.
    @_spi(PO)
    public convenience init(poResource resource: POColorResource) {
        // swiftlint:disable:next force_unwrapping
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
    }
}

// swiftlint:enable strict_fileprivate nesting
