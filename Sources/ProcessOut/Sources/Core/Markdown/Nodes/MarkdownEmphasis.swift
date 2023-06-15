//
//  MarkdownEmphasis.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.06.2023.
//

@_implementationOnly import cmark

final class MarkdownEmphasis: MarkdownNode {

    // MARK: - MarkdownNode

    override class var cmarkNodeType: cmark_node_type {
        CMARK_NODE_EMPH
    }

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(node: self)
    }
}
