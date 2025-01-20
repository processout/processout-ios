//
//  POTypography+Symbols.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 15.10.2024.
//

import UIKit

@_spi(PO)
@available(*, deprecated)
extension POTypography {

    /// Use for extra large titles.
    public static let extraLargeTitle = POTypography(font: UIFont(.WorkSans.regular, size: 36))

    /// Use for titles.
    public static let title = POTypography(font: UIFont(.WorkSans.medium, size: 20), lineHeight: 24)

    /// Subheading typography.
    public static let subheading = POTypography(font: UIFont(.WorkSans.medium, size: 18), lineHeight: 24)

    /// Primary body text for readability and consistency.
    public static let body1 = POTypography(font: UIFont(.WorkSans.medium, size: 16), lineHeight: 24)

    /// Secondary body text for supporting content.
    public static let body2 = POTypography(font: UIFont(.WorkSans.regular, size: 14), lineHeight: 18)

    /// Tertiary body text for supporting content.
    public static let body3 = POTypography(font: UIFont(.WorkSans.regular, size: 16))

    /// Text used on buttons or interactive elements.
    public static let button = POTypography(font: UIFont(.WorkSans.medium, size: 14), lineHeight: 18)

    /// Large text for prominent labels or headings.
    public static let label1 = POTypography(font: UIFont(.WorkSans.medium, size: 14), lineHeight: 18)

    /// Smaller text for secondary labels or headings.
    public static let label2 = POTypography(font: UIFont(.WorkSans.regular, size: 14), lineHeight: 18)

    /// Registers all custom fonts.
    public static func registerFonts() {
        FontResource.register()
    }
}

@_spi(PO)
extension POTypography {

    public enum Header {

        public static func s18(weight: UIFont.Weight = .regular) -> POTypography {
            validateWeight(weight: weight)
            return .init(font: .init(.workSans(withWeight: weight), size: 18), lineHeight: 22)
        }

        public static func s20(weight: UIFont.Weight = .regular) -> POTypography {
            validateWeight(weight: weight)
            if #available(iOS 16, *) {
                let kernings: [UIFont.Weight: CGFloat] = [.regular: -0.2, .medium: -0.15, .semibold: -0.1]
                let kerning = kernings[weight] ?? 0.0
                return .init(font: .init(.workSans(withWeight: weight), size: 20), lineHeight: 22, kerning: kerning)
            }
            return .init(font: .init(.workSans(withWeight: weight), size: 20), lineHeight: 22)
        }

        public static func s24(weight: UIFont.Weight = .regular) -> POTypography {
            validateWeight(weight: weight)
            return .init(font: .init(.workSans(withWeight: weight), size: 24), lineHeight: 28)
        }

        public static func s28(weight: UIFont.Weight = .regular) -> POTypography {
            // Height should be different when weight is semibold.
            validateWeight(weight: weight)
            return .init(font: .init(.workSans(withWeight: weight), size: 28), lineHeight: 32)
        }

        public static func s32(weight: UIFont.Weight = .regular) -> POTypography {
            validateWeight(weight: weight)
            return .init(font: .init(.workSans(withWeight: weight), size: 32), lineHeight: 40)
        }

        public static func s36(weight: UIFont.Weight = .regular) -> POTypography {
            validateWeight(weight: weight)
            return .init(font: .init(.workSans(withWeight: weight), size: 36), lineHeight: 44)
        }

        public static func s40(weight: UIFont.Weight = .regular) -> POTypography {
            validateWeight(weight: weight)
            if #available(iOS 16, *) {
                let kernings: [UIFont.Weight: CGFloat] = [.regular: -0.3, .medium: -0.25, .semibold: -0.2]
                let kerning = kernings[weight] ?? 0.0
                return .init(font: .init(.workSans(withWeight: weight), size: 40), lineHeight: 48, kerning: kerning)
            }
            return .init(font: .init(.workSans(withWeight: weight), size: 40), lineHeight: 48)
        }

        public static func s48(weight: UIFont.Weight = .regular) -> POTypography {
            validateWeight(weight: weight)
            return .init(font: .init(.workSans(withWeight: weight), size: 48), lineHeight: 56)
        }

        public static func s64(weight: UIFont.Weight = .regular) -> POTypography {
            validateWeight(weight: weight)
            if #available(iOS 16, *) {
                let kernings: [UIFont.Weight: CGFloat] = [.regular: -1, .medium: -0.8, .semibold: -0.6]
                let kerning = kernings[weight] ?? 0.0
                return .init(font: .init(.workSans(withWeight: weight), size: 64), lineHeight: 80, kerning: kerning)
            }
            return .init(font: .init(.workSans(withWeight: weight), size: 64), lineHeight: 80)
        }
    }

    public enum Text {

        public static func s12(weight: UIFont.Weight = .regular) -> POTypography {
            validateWeight(weight: weight)
            if #available(iOS 16, *) {
                return .init(font: .init(.workSans(withWeight: weight), size: 12), lineHeight: 14, kerning: 0.15)
            }
            return .init(font: .init(.workSans(withWeight: weight), size: 12), lineHeight: 14)
        }

        public static func s13(weight: UIFont.Weight = .regular) -> POTypography {
            validateWeight(weight: weight)
            return .init(font: .init(.workSans(withWeight: weight), size: 13), lineHeight: 16)
        }

        public static func s14(weight: UIFont.Weight = .regular) -> POTypography {
            validateWeight(weight: weight)
            if #available(iOS 16, *) {
                return .init(font: .init(.workSans(withWeight: weight), size: 14), lineHeight: 18, kerning: 0.15)
            }
            return .init(font: .init(.workSans(withWeight: weight), size: 14), lineHeight: 18)
        }

        public static func s15(weight: UIFont.Weight = .regular) -> POTypography {
            validateWeight(weight: weight)
            return .init(font: .init(.workSans(withWeight: weight), size: 15), lineHeight: 18)
        }

        public static func s16(weight: UIFont.Weight = .regular) -> POTypography {
            validateWeight(weight: weight)
            return .init(font: .init(.workSans(withWeight: weight), size: 16), lineHeight: 20)
        }

        public static func s18(weight: UIFont.Weight = .regular) -> POTypography {
            validateWeight(weight: weight)
            if #available(iOS 16, *) {
                let kernings: [UIFont.Weight: CGFloat] = [.medium: 0.1, .semibold: 0.1]
                let kerning = kernings[weight] ?? 0.0
                return .init(font: .init(.workSans(withWeight: weight), size: 18), lineHeight: 22, kerning: kerning)
            }
            return .init(font: .init(.workSans(withWeight: weight), size: 18), lineHeight: 22)
        }

        public static func s20(weight: UIFont.Weight = .regular) -> POTypography {
            validateWeight(weight: weight)
            if #available(iOS 16, *) {
                let kernings: [UIFont.Weight: CGFloat] = [.regular: -0.2, .medium: -0.15, .semibold: -0.1]
                let kerning = kernings[weight] ?? 0.0
                return .init(font: .init(.workSans(withWeight: weight), size: 20), lineHeight: 24, kerning: kerning)
            }
            return .init(font: .init(.workSans(withWeight: weight), size: 20), lineHeight: 24)
        }

        public static func s24(weight: UIFont.Weight = .regular) -> POTypography {
            validateWeight(weight: weight)
            return .init(font: .init(.workSans(withWeight: weight), size: 24), lineHeight: 28)
        }
    }

    public enum Paragraph {

        public static func s14(weight: UIFont.Weight = .regular) -> POTypography {
            validateWeight(weight: weight)
            return .init(font: .init(.workSans(withWeight: weight), size: 14), lineHeight: 24, paragraphSpacing: 24)
        }

        public static func s16(weight: UIFont.Weight = .regular) -> POTypography {
            validateWeight(weight: weight)
            return .init(font: .init(.workSans(withWeight: weight), size: 16), lineHeight: 28, paragraphSpacing: 28)
        }

        public static func s18(weight: UIFont.Weight = .regular) -> POTypography {
            validateWeight(weight: weight)
            if #available(iOS 16, *) {
                let kernings: [UIFont.Weight: CGFloat] = [.medium: 0.1, .semibold: 0.1]
                return .init(
                    font: .init(.workSans(withWeight: weight), size: 18),
                    lineHeight: 32,
                    paragraphSpacing: 32,
                    kerning: kernings[weight] ?? 0.0
                )
            }
            return .init(font: .init(.workSans(withWeight: weight), size: 18), lineHeight: 32, paragraphSpacing: 32)
        }

        public static func s20(weight: UIFont.Weight = .regular) -> POTypography {
            validateWeight(weight: weight)
            if #available(iOS 16, *) {
                let kernings: [UIFont.Weight: CGFloat] = [.regular: -0.2, .medium: -0.15, .semibold: -0.1]
                return .init(
                    font: .init(.workSans(withWeight: weight), size: 20),
                    lineHeight: 32,
                    paragraphSpacing: 32,
                    kerning: kernings[weight] ?? 0.0
                )
            }
            return .init(font: .init(.workSans(withWeight: weight), size: 20), lineHeight: 32, paragraphSpacing: 32)
        }

        public static func s24(weight: UIFont.Weight = .regular) -> POTypography {
            validateWeight(weight: weight)
            return .init(font: .init(.workSans(withWeight: weight), size: 24), lineHeight: 40, paragraphSpacing: 36)
        }
    }

    // MARK: - Private Methods

    private static func validateWeight(weight: UIFont.Weight) {
        let supportedWeights: Set<UIFont.Weight> = [.regular, .medium, .semibold]
        precondition(supportedWeights.contains(weight), "Weight \(weight) is not supported by design system.")
    }
}
