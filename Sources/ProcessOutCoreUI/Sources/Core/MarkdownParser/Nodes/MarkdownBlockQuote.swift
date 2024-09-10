//
//  MarkdownBlockQuote.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 15.06.2023.
//

import cmark_gfm

final class MarkdownBlockQuote: MarkdownBaseNode, @unchecked Sendable {

    override static var cmarkNodeType: cmark_node_type {
        CMARK_NODE_BLOCK_QUOTE
    }

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(blockQuote: self)
    }
}
