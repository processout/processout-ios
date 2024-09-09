//
//  MarkdownStrong.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 12.06.2023.
//

import cmark_gfm

final class MarkdownStrong: MarkdownBaseNode {

    // MARK: - MarkdownBaseNode

    override static var cmarkNodeType: cmark_node_type {
        CMARK_NODE_STRONG
    }

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(strong: self)
    }
}
