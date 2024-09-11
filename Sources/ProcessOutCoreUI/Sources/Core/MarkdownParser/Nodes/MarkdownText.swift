//
//  MarkdownText.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 12.06.2023.
//

import cmark_gfm

final class MarkdownText: MarkdownBaseNode, @unchecked Sendable {

    /// Text value.
    let value: String

    // MARK: - MarkdownBaseNode

    required init(cmarkNode: MarkdownBaseNode.CmarkNode, validatesType: Bool = true) {
        if let literal = cmark_node_get_literal(cmarkNode) {
            value = String(cString: literal)
        } else {
            assertionFailure("Unable to get text node value")
            value = ""
        }
        super.init(cmarkNode: cmarkNode, validatesType: validatesType)
    }

    override static var cmarkNodeType: cmark_node_type {
        CMARK_NODE_TEXT
    }

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(text: self)
    }
}
