//
//  MarkdownSoftbreak.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 15.06.2023.
//

@_implementationOnly import cmark

final class MarkdownSoftbreak: MarkdownBaseNode {

    override class var cmarkNodeType: cmark_node_type {
        CMARK_NODE_SOFTBREAK
    }

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(node: self)
    }
}
