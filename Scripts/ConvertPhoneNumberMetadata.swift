#!/usr/bin/env swift

import Foundation

let source = URL(filePath: CommandLine.arguments[1])
let metadata = PhoneNumbersMetadataParser().parse(contentsOf: source) ?? []

let encoder = JSONEncoder()
encoder.outputFormatting = [.sortedKeys]
let encodedMetadata = try encoder.encode(metadata)

let targetPath = CommandLine.arguments[2]
FileManager.default.createFile(atPath: targetPath, contents: encodedMetadata)

// MARK: -

struct MutablePhoneNumberMetadataFormat: Encodable {

    /// Pattern.
    var pattern: String?

    /// Leading digits.
    var leading: [String] = []

    /// Format.
    var format: String?
}

struct MutablePhoneNumberMetadata: Encodable {

    /// Country code.
    var countryCode: String?

    /// Formats.
    var formats: [MutablePhoneNumberMetadataFormat] = []
}

final class PhoneNumbersMetadataParser: NSObject, XMLParserDelegate {

    override init() {
        currentFormat = MutablePhoneNumberMetadataFormat()
        currentMetadata = MutablePhoneNumberMetadata()
        currentValue = ""
        metadata = []
        super.init()
    }

    func parse(contentsOf url: URL) -> [MutablePhoneNumberMetadata]? {
        guard let parser = XMLParser(contentsOf: url) else {
            return nil
        }
        parser.delegate = self
        guard parser.parse() else {
            return nil
        }
        return metadata
    }

    // MARK: - XMLParserDelegate

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes: [String: String]
    ) {
        guard let element = Element(rawValue: elementName) else {
            return
        }
        switch element {
        case .territory:
            currentMetadata.countryCode = attributes[Attribute.countryCode.rawValue]
        case .numberFormat:
            currentFormat.pattern = attributes[Attribute.pattern.rawValue]
        default:
            break
        }
        currentValue = ""
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard let element = Element(rawValue: elementName) else {
            return
        }
        switch element {
        case .territory:
            if isCurrentMetadataValid {
                metadata.append(currentMetadata)
            }
            currentMetadata = MutablePhoneNumberMetadata()
        case .numberFormat:
            if isCurrentFormatValid {
                currentMetadata.formats.append(currentFormat)
            }
            currentFormat = MutablePhoneNumberMetadataFormat()
        case .leadingDigits:
            let filteredValue = currentValue.replacingOccurrences(of: "\\s", with: "", options: .regularExpression, range: nil)
            currentFormat.leading.append(filteredValue)
        case .format:
            // We want to use format if international format wasn't set before
            if currentFormat.format == nil {
                currentFormat.format = currentValue
            }
        case .intlFormat where currentValue != "NA":
            currentFormat.format = currentValue
        default:
            return
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // Removes redundant indentation.
        currentValue += string
    }

    // MARK: - Private Nested Types

    private enum Element: String {
        case territory, availableFormats, numberFormat, leadingDigits, format, intlFormat
    }

    private enum Attribute: String {
        case countryCode, pattern
    }

    // MARK: - Private Properties

    private var currentFormat: MutablePhoneNumberMetadataFormat
    private var currentMetadata: MutablePhoneNumberMetadata
    private var currentValue: String
    private var metadata: [MutablePhoneNumberMetadata]

    // MARK: - Private Methods

    private var isCurrentFormatValid: Bool {
        currentFormat.format != nil && currentFormat.pattern != nil && !currentFormat.leading.isEmpty
    }

    private var isCurrentMetadataValid: Bool {
        currentMetadata.countryCode != nil && !currentMetadata.formats.isEmpty
    }
}
