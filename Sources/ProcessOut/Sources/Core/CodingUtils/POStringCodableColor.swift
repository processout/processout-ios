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
public struct POStringCodableColor: Decodable {

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
}

extension KeyedDecodingContainer {

    func decode(_ type: POStringCodableColor.Type, forKey key: K) throws -> POStringCodableColor {
        try type.init(from: try superDecoder(forKey: key))
    }
}
