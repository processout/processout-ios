//
//  MarkdownThematicBreak.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 15.06.2023.
//

@_implementationOnly import cmark

final class MarkdownThematicBreak: MarkdownNode {

    override class var rawType: cmark_node_type {
        CMARK_NODE_THEMATIC_BREAK
    }

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(node: self)
    }
}
