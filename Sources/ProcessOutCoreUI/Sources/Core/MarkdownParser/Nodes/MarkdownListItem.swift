//
//  MarkdownListItem.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 12.06.2023.
//

@_implementationOnly import cmark

final class MarkdownListItem: MarkdownBaseNode, @unchecked Sendable {

    override static var cmarkNodeType: cmark_node_type {
        CMARK_NODE_ITEM
    }

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(listItem: self)
    }
}
