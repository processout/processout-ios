//
//  MarkdownStrong.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.06.2023.
//

import cmark

final class MarkdownStrong: MarkdownNode {

    // MARK: - MarkdownNode

    override class var rawType: cmark_node_type {
        CMARK_NODE_STRONG
    }

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(node: self)
    }
}
