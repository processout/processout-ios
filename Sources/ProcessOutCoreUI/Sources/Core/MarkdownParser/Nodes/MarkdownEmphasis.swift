//
//  MarkdownEmphasis.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 12.06.2023.
//

@_implementationOnly import cmark

final class MarkdownEmphasis: MarkdownBaseNode {

    // MARK: - MarkdownBaseNode

    override class var cmarkNodeType: cmark_node_type {
        CMARK_NODE_EMPH
    }

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(emphasis: self)
    }
}
