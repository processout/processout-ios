#!/usr/bin/env swift

import Foundation

// Decode metadata
let sourceUrl = URL(filePath: CommandLine.arguments[1])
let metadata = try JSONDecoder().decode(
    Metadata.self, from: Data(contentsOf: sourceUrl)
)

// Encode metadata
let encoder = JSONEncoder()
encoder.outputFormatting = [.sortedKeys]
let encodedMetadata = try encoder.encode(metadata.phoneNumberMetadata.territories.territory)

// Write metadata
let targetPath = CommandLine.arguments[2]
FileManager.default.createFile(atPath: targetPath, contents: encodedMetadata)

// MARK: - Models

struct Metadata: Decodable {

    struct AvailableFormats {
        let numberFormat: [NumberFormat]?
    }

    struct NumberFormat {
        let pattern, format: String, leadingDigits: [String]
    }

    struct Territory {
        let id: String, countryCode: String, availableFormats: AvailableFormats?
    }

    struct Territories: Decodable {
        let territory: [Territory]
    }

    struct PhoneNumberMetadata: Decodable {
        let territories: Territories
    }

    let phoneNumberMetadata: PhoneNumberMetadata
}

extension Metadata.NumberFormat: Codable {

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: DecodingKeys.self)
        pattern = try container.decode(String.self, forKey: .pattern)
        do {
            if let leading = try container.decodeIfPresent(String.self, forKey: .leadingDigits) {
                leadingDigits = [leading]
            } else {
                leadingDigits = []
            }
        } catch {
            leadingDigits = try container.decodeIfPresent([String].self, forKey: .leadingDigits) ?? []
        }
        format = try container.decode(String.self, forKey: .format)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        try container.encode(pattern, forKey: .pattern)
        try container.encode(leadingDigits, forKey: .leading)
        try container.encode(format, forKey: .format)
    }

    // MARK: - Private Properties

    private enum DecodingKeys: CodingKey {
        case pattern, leadingDigits, format
    }

    private enum EncodingKeys: CodingKey {
        case pattern, leading, format
    }
}

extension Metadata.Territory: Codable {

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: DecodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        countryCode = try container.decode(String.self, forKey: .countryCode)
        availableFormats = try container.decodeIfPresent(Metadata.AvailableFormats.self, forKey: .availableFormats)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(countryCode, forKey: .countryCode)
        try container.encode(availableFormats?.numberFormat ?? [], forKey: .formats)
    }

    // MARK: - Private Properties

    private enum DecodingKeys: CodingKey {
        case id, countryCode, availableFormats
    }

    private enum EncodingKeys: CodingKey {
        case id, countryCode, formats
    }
}

extension Metadata.AvailableFormats: Decodable {

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: DecodingKeys.self)
        do {
            numberFormat = try container.decode([Metadata.NumberFormat].self, forKey: .numberFormat)
        } catch {
            numberFormat = [try container.decode(Metadata.NumberFormat.self, forKey: .numberFormat)]
        }
    }

    // MARK: - Private Properties

    private enum DecodingKeys: CodingKey {
        case numberFormat
    }
}