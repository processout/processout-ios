//
//  MarkdownSoftbreak.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 15.06.2023.
//

@_implementationOnly import cmark

final class MarkdownSoftbreak: MarkdownBaseNode, @unchecked Sendable {

    override static var cmarkNodeType: cmark_node_type {
        CMARK_NODE_SOFTBREAK
    }

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(softbreak: self)
    }
}
