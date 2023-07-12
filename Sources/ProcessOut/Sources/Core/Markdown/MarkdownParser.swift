//
//  MarkdownParser.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.06.2023.
//

import Foundation
@_implementationOnly import cmark

enum MarkdownParser {

    static func parse(string: String) -> MarkdownDocument {
        let document = string.withCString { pointer in
            cmark_parse_document(pointer, strlen(pointer), CMARK_OPT_SMART)
        }
        guard let document else {
            preconditionFailure("Failed to parse markdown document")
        }
        return MarkdownDocument(cmarkNode: document)
    }

    /// Escapes given plain text so it can be represented as is, in markdown.
    static func escaped(plainText: String) -> String {
        var markdown = String()
        markdown.reserveCapacity(plainText.count)
        for character in plainText {
            if character.unicodeScalars.allSatisfy(Constants.specialCharacters.contains) {
                markdown += Constants.escapeCharacter
            }
            markdown += String(character)
        }
        return markdown
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let specialCharacters = CharacterSet(charactersIn: "\\`*_{}[]()#+-.!")
        static let escapeCharacter = "\\"
    }
}
