//
//  MarkdownParser.swift
//  ProcessOutCoreUI
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
}
