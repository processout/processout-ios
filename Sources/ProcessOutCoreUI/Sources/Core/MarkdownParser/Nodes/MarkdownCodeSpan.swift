//
//  MarkdownCodeSpan.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 15.06.2023.
//

import cmark_gfm

final class MarkdownCodeSpan: MarkdownBaseNode {

    private(set) lazy var code: String = {
        guard let literal = cmark_node_get_literal(cmarkNode) else {
            assertionFailure("Unable to get text node value")
            return ""
        }
        return String(cString: literal)
    }()

    // MARK: - MarkdownBaseNode

    override static var cmarkNodeType: cmark_node_type {
        CMARK_NODE_CODE
    }

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(codeSpan: self)
    }
}
