//
//  MarkdownParagraph.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.06.2023.
//

import cmark

final class MarkdownParagraph: MarkdownNode {

    // MARK: - MarkdownNode

    override class var rawType: cmark_node_type {
        CMARK_NODE_PARAGRAPH
    }

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(node: self)
    }
}
