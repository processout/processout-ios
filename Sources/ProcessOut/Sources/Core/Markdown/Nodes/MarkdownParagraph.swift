//
//  MarkdownParagraph.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.06.2023.
//

@_implementationOnly import cmark

final class MarkdownParagraph: MarkdownNode {

    // MARK: - MarkdownNode

    override class var cmarkNodeType: cmark_node_type {
        CMARK_NODE_PARAGRAPH
    }

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(node: self)
    }
}
