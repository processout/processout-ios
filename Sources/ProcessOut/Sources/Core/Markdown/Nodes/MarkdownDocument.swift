//
//  MarkdownDocument.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 11.06.2023.
//

import cmark_gfm

final class MarkdownDocument: MarkdownBaseNode {

    deinit {
        cmark_node_free(cmarkNode)
    }

    // MARK: - MarkdownBaseNode

    override static var cmarkNodeType: cmark_node_type {
        CMARK_NODE_DOCUMENT
    }

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(document: self)
    }
}
