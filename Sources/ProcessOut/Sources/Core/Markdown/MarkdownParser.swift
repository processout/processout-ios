//
//  MarkdownParser.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.06.2023.
//

@_implementationOnly import cmark

final class MarkdownParser {

    func parse(string: String) -> MarkdownDocument {
        let document = string.withCString { pointer in
            cmark_parse_document(pointer, strlen(pointer), CMARK_OPT_SMART)
        }
        guard let document else {
            preconditionFailure("Failed to parse markdown document")
        }
        return MarkdownDocument(cmarkNode: document)
    }
}
