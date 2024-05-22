//
//  MarkdownLink.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 15.06.2023.
//

@_implementationOnly import cmark

final class MarkdownLink: MarkdownBaseNode {

    private(set) lazy var url: String? = {
        if let url = cmarkNode.pointee.as.link.url {
            return String(cString: url)
        }
        return nil
    }()

    // MARK: - MarkdownBaseNode

    override static var cmarkNodeType: cmark_node_type {
        CMARK_NODE_LINK
    }

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(link: self)
    }
}
