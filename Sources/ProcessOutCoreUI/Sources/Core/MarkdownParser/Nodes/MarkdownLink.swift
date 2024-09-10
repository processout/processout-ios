//
//  MarkdownLink.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 15.06.2023.
//

import cmark_gfm

final class MarkdownLink: MarkdownBaseNode {

    private(set) lazy var url: String? = {
        String(cString: cmarkNode.pointee.as.link.url.data)
    }()

    // MARK: - MarkdownBaseNode

    override static var cmarkNodeType: cmark_node_type {
        CMARK_NODE_LINK
    }

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(link: self)
    }
}
