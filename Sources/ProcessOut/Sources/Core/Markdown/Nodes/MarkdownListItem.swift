//
//  MarkdownListItem.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.06.2023.
//

@_implementationOnly import cmark

final class MarkdownListItem: MarkdownBaseNode {

    // MARK: - MarkdownBaseNode

    override class var cmarkNodeType: cmark_node_type {
        CMARK_NODE_ITEM
    }

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(node: self)
    }
}
