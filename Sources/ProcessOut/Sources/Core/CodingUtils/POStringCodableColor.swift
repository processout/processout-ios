//
//  POStringCodableColor.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.04.2024.
//

import Foundation
import UIKit

/// Property wrapper that allows to decode UIColor from string representations.
@propertyWrapper
public struct POStringCodableColor: Codable, Sendable {

    public var wrappedValue: UIColor

    /// Creates property wrapper instance.
    public init(value: UIColor) {
        self.wrappedValue = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let lightColor = try Self.decodeColor(
            from: try container.decode(String.self, forKey: .light), codingPath: decoder.codingPath
        )
        let darkColor = try container.decodeIfPresent(String.self, forKey: .dark).map { string in
            try Self.decodeColor(from: string, codingPath: decoder.codingPath)
        }
        let dynamicColor = UIColor { traits in
            if case .dark = traits.userInterfaceStyle, let darkColor {
                return darkColor
            }
            return lightColor
        }
        self.wrappedValue = dynamicColor
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Self.encodeColor(wrappedValue, style: .light), forKey: .light)
        try container.encode(Self.encodeColor(wrappedValue, style: .dark), forKey: .dark)
    }

    // MARK: - Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case light, dark
    }

    // MARK: - Private Methods

    private static func decodeColor(from string: String, codingPath: [CodingKey]) throws -> UIColor {
        var value: UInt64 = 0
        guard Scanner(string: string).scanHexInt64(&value) else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Invalid color value.")
            throw DecodingError.dataCorrupted(context)
        }
        let red   = CGFloat(value >> 24 & 0xFF) / 255
        let green = CGFloat(value >> 16 & 0xFF) / 255
        let blue  = CGFloat(value >> 08 & 0xFF) / 255
        let alpha = CGFloat(value & 0xFF) / 255
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    private static func encodeColor(_ color: UIColor, style: UIUserInterfaceStyle) -> String {
        let resolvedColor = color.resolvedColor(
            with: .init(userInterfaceStyle: style)
        )
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        resolvedColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        // swiftlint:disable operator_usage_whitespace
        let encodedColor =
            (Int(red   * 255) & 0xFF) << 24 |
            (Int(green * 255) & 0xFF) << 16 |
            (Int(blue  * 255) & 0xFF) << 08 |
             Int(alpha * 255) & 0xFF
        // swiftlint:enable operator_usage_whitespace
        return String(encodedColor, radix: 16, uppercase: true)
    }
}
