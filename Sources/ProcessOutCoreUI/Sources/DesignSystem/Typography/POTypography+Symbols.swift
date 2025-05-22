//
//  POTypography+Symbols.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 15.10.2024.
//

import UIKit

@_spi(PO)
extension POTypography {

    public enum Text {

        public static func s12(weight: UIFont.Weight = .regular) -> POTypography {
            validateWeight(weight: weight)
            if #available(iOS 16, *) {
                return .init(font: .init(.workSans(withWeight: weight), size: 12), kerning: 0.15)
            }
            return .init(font: .init(.workSans(withWeight: weight), size: 12))
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
            return .init(font: .init(.workSans(withWeight: weight), size: 24))
        }
    }

    public enum Paragraph {

        public static func s16(weight: UIFont.Weight = .regular) -> POTypography {
            validateWeight(weight: weight)
            return .init(font: .init(.workSans(withWeight: weight), size: 16), lineHeight: 28, paragraphSpacing: 28)
        }
    }

    /// Registers all custom fonts.
    public static func registerFonts() {
        FontResource.register()
    }

    // MARK: - Private Methods

    private static func validateWeight(weight: UIFont.Weight) {
        let supportedWeights: Set<UIFont.Weight> = [.regular, .medium, .semibold]
        precondition(supportedWeights.contains(weight), "Weight \(weight) is not supported by design system.")
    }
}
