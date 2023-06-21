//
//  MarkdownDocument.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 11.06.2023.
//

@_implementationOnly import cmark

final class MarkdownDocument: MarkdownBaseNode {

    deinit {
        cmark_node_free(cmarkNode)
    }

    // MARK: - MarkdownBaseNode

    override class var cmarkNodeType: cmark_node_type {
        CMARK_NODE_DOCUMENT
    }

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(document: self)
    }
}
