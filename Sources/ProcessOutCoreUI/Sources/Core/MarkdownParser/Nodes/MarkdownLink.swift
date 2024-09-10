//
//  MarkdownLink.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 15.06.2023.
//

import cmark_gfm

final class MarkdownLink: MarkdownBaseNode, @unchecked Sendable {

    let url: String?

    // MARK: - MarkdownBaseNode

    required init(cmarkNode: MarkdownBaseNode.CmarkNode, validatesType: Bool = true) {
        self.url = String(cString: cmarkNode.pointee.as.link.url.data)
        super.init(cmarkNode: cmarkNode, validatesType: validatesType)
    }

    override static var cmarkNodeType: cmark_node_type {
        CMARK_NODE_LINK
    }

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(link: self)
    }
}
