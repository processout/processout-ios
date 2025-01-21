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

            /// The "Button/Primary/Title" asset catalog resource namespace.
            public enum Title {

                /// The "Button/Primary/Title/Default" asset catalog color resource.
                public static let `default` = POColorResource(name: "Button/Primary/Title/Default")

                /// The "Button/Primary/Title/Disabled" asset catalog color resource.
                public static let disabled = POColorResource(name: "Button/Primary/Title/Disabled")

                /// The "Button/Primary/Title/Pressed" asset catalog color resource.
                public static let pressed = POColorResource(name: "Button/Primary/Title/Pressed")
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

            /// The "Button/Secondary/Title" asset catalog resource namespace.
            public enum Title {

                /// The "Button/Secondary/Title/Default" asset catalog color resource.
                public static let `default` = POColorResource(name: "Button/Secondary/Title/Default")

                /// The "Button/Secondary/Title/Disabled" asset catalog color resource.
                public static let disabled = POColorResource(name: "Button/Secondary/Title/Disabled")

                /// The "Button/Secondary/Title/Pressed" asset catalog color resource.
                public static let pressed = POColorResource(name: "Button/Secondary/Title/Pressed")
            }
        }

        /// The "Button/Ghost" asset catalog resource namespace.
        public enum Ghost {

            /// The "Button/Ghost/Background" asset catalog resource namespace.
            public enum Background {

                /// The "Button/Ghost/Background/Default" asset catalog color resource.
                public static let `default` = POColorResource(name: "Button/Ghost/Background/Default")

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

                /// The "Button/Ghost/Title/Selected" asset catalog color resource.
                public static let selected = POColorResource(name: "Button/Ghost/Title/Selected")
            }
        }
    }

    /// The "Input" asset catalog resource namespace.
    @available(*, deprecated)
    public enum Input {

        /// The "Input/Background" asset catalog resource namespace.
        public enum Background {

            /// The "Input/Background/Default" asset catalog color resource.
            public static let `default` = POColorResource(name: "Input/Background/Default")

            /// The "Input/Background/Disabled" asset catalog color resource.
            public static let disabled = POColorResource(name: "Input/Background/Disabled")

            /// The "Input/Background/Error" asset catalog color resource.
            public static let error = POColorResource(name: "Input/Background/Error")

            /// The "Input/Background/Focused" asset catalog color resource.
            public static let focused = POColorResource(name: "Input/Background/Focused")
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
        }

        /// The "Input/Placeholder" asset catalog resource namespace.
        public enum Placeholder {

            /// The "Input/Placeholder/Default" asset catalog color resource.
            public static let `default` = POColorResource(name: "Input/Placeholder/Default")

            /// The "Input/Placeholder/Disabled" asset catalog color resource.
            public static let disabled = POColorResource(name: "Input/Placeholder/Disabled")

            /// The "Input/Placeholder/Error" asset catalog color resource.
            public static let error = POColorResource(name: "Input/Placeholder/Error")

            /// The "Input/Placeholder/Focused" asset catalog color resource.
            public static let focused = POColorResource(name: "Input/Placeholder/Focused")
        }

        /// The "Input/Text" asset catalog resource namespace.
        public enum Text {

            /// The "Input/Text/Default" asset catalog color resource.
            public static let `default` = POColorResource(name: "Input/Text/Default")

            /// The "Input/Text/Disabled" asset catalog color resource.
            public static let disabled = POColorResource(name: "Input/Text/Disabled")

            /// The "Input/Text/Error" asset catalog color resource.
            public static let error = POColorResource(name: "Input/Text/Error")

            /// The "Input/Text/Focused" asset catalog color resource.
            public static let focused = POColorResource(name: "Input/Text/Focused")
        }

        /// The "Input/Tint" asset catalog resource namespace.
        public enum Tint {

            /// The "Input/Tint/Default" asset catalog color resource.
            public static let `default` = POColorResource(name: "Input/Tint/Default")

            /// The "Input/Tint/Disabled" asset catalog color resource.
            public static let disabled = POColorResource(name: "Input/Tint/Disabled")

            /// The "Input/Tint/Error" asset catalog color resource.
            public static let error = POColorResource(name: "Input/Tint/Error")

            /// The "Input/Tint/Focused" asset catalog color resource.
            public static let focused = POColorResource(name: "Input/Tint/Focused")
        }
    }

    /// The "Radio" asset catalog resource namespace.
    public enum Radio {

        /// The "Radio/Knob" asset catalog resource namespace.
        public enum Knob {

            /// The "Radio/Knob/Background" asset catalog resource namespace.
            public enum Background {

                /// The "Radio/Knob/Background/Default" asset catalog color resource.
                public static let `default` = POColorResource(name: "Radio/Knob/Background/Default")

                /// The "Radio/Knob/Background/Disabled" asset catalog color resource.
                public static let disabled = POColorResource(name: "Radio/Knob/Background/Disabled")

                /// The "Radio/Knob/Background/Error" asset catalog color resource.
                public static let error = POColorResource(name: "Radio/Knob/Background/Error")

                /// The "Radio/Knob/Background/Pressed" asset catalog color resource.
                public static let pressed = POColorResource(name: "Radio/Knob/Background/Pressed")

                /// The "Radio/Knob/Background/Selected" asset catalog color resource.
                public static let selected = POColorResource(name: "Radio/Knob/Background/Selected")
            }

            /// The "Radio/Knob/Border" asset catalog resource namespace.
            public enum Border {

                /// The "Radio/Knob/Border/Default" asset catalog color resource.
                public static let `default` = POColorResource(name: "Radio/Knob/Border/Default")

                /// The "Radio/Knob/Border/Disabled" asset catalog color resource.
                public static let disabled = POColorResource(name: "Radio/Knob/Border/Disabled")

                /// The "Radio/Knob/Border/Error" asset catalog color resource.
                public static let error = POColorResource(name: "Radio/Knob/Border/Error")

                /// The "Radio/Knob/Border/Pressed" asset catalog color resource.
                public static let pressed = POColorResource(name: "Radio/Knob/Border/Pressed")

                /// The "Radio/Knob/Border/Selected" asset catalog color resource.
                public static let selected = POColorResource(name: "Radio/Knob/Border/Selected")
            }

            /// The "Radio/Knob/Value" asset catalog resource namespace.
            public enum Value {

                /// The "Radio/Knob/Value/Default" asset catalog color resource.
                public static let `default` = POColorResource(name: "Radio/Knob/Value/Default")

                /// The "Radio/Knob/Value/Disabled" asset catalog color resource.
                public static let disabled = POColorResource(name: "Radio/Knob/Value/Disabled")

                /// The "Radio/Knob/Value/Error" asset catalog color resource.
                public static let error = POColorResource(name: "Radio/Knob/Value/Error")

                /// The "Radio/Knob/Value/Pressed" asset catalog color resource.
                public static let pressed = POColorResource(name: "Radio/Knob/Value/Pressed")

                /// The "Radio/Knob/Value/Selected" asset catalog color resource.
                public static let selected = POColorResource(name: "Radio/Knob/Value/Selected")
            }
        }

        /// The "Radio/Text" asset catalog resource namespace.
        public enum Text {

            /// The "Radio/Text/Default" asset catalog color resource.
            public static let `default` = POColorResource(name: "Radio/Text/Default")

            /// The "Radio/Text/Disabled" asset catalog color resource.
            public static let disabled = POColorResource(name: "Radio/Text/Disabled")

            /// The "Radio/Text/Error" asset catalog color resource.
            public static let error = POColorResource(name: "Radio/Text/Error")

            /// The "Radio/Text/Pressed" asset catalog color resource.
            public static let pressed = POColorResource(name: "Radio/Text/Pressed")

            /// The "Radio/Text/Selected" asset catalog color resource.
            public static let selected = POColorResource(name: "Radio/Text/Selected")
        }

        /// The "Radio/Background" asset catalog resource namespace.
        public enum Background {

            /// The "Radio/Background/Default" asset catalog color resource.
            public static let `default` = POColorResource(name: "Radio/Background/Default")

            /// The "Radio/Background/Disabled" asset catalog color resource.
            public static let disabled = POColorResource(name: "Radio/Background/Disabled")

            /// The "Radio/Background/Error" asset catalog color resource.
            public static let error = POColorResource(name: "Radio/Background/Error")

            /// The "Radio/Background/Pressed" asset catalog color resource.
            public static let pressed = POColorResource(name: "Radio/Background/Pressed")

            /// The "Radio/Background/Selected" asset catalog color resource.
            public static let selected = POColorResource(name: "Radio/Background/Selected")
        }
    }

    /// The "Surface" asset catalog resource namespace.
    public enum Surface {

        /// The "Surface/Default" asset catalog color resource.
        public static let `default` = POColorResource(name: "Surface/Default")

        /// The "Surface/SuccessSubtle" asset catalog color resource.
        public static let successSubtle = POColorResource(name: "Surface/SuccessSubtle")

        /// The "Surface/ErrorSubtle" asset catalog color resource.
        public static let errorSubtle = POColorResource(name: "Surface/ErrorSubtle")
    }

    /// The "Text" asset catalog resource namespace.
    public enum Text {

        /// The "Text/Primary" asset catalog color resource.
        public static let primary = POColorResource(name: "Text/Primary")

        /// The "Text/Secondary" asset catalog color resource.
        public static let secondary = POColorResource(name: "Text/Secondary")

        /// The "Text/Tertiary" asset catalog color resource.
        public static let tertiary = POColorResource(name: "Text/Tertiary")

        /// The "Text/Inverse" asset catalog color resource.
        public static let inverse = POColorResource(name: "Text/Inverse")

        /// The "Text/Disabled" asset catalog color resource.
        public static let disabled = POColorResource(name: "Text/Disabled")

        /// The "Text/Success" asset catalog color resource.
        public static let success = POColorResource(name: "Text/Success")

        /// The "Text/Error" asset catalog color resource.
        public static let error = POColorResource(name: "Text/Error")
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
