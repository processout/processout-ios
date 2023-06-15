//
//  MarkdownLink.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 15.06.2023.
//

@_implementationOnly import cmark

final class MarkdownLink: MarkdownNode {

    private(set) lazy var title: String? = {
        if let url = rawNode.pointee.as.link.title {
            return String(cString: url)
        }
        return nil
    }()

    private(set) lazy var url: String? = {
        if let url = rawNode.pointee.as.link.url {
            return String(cString: url)
        }
        return nil
    }()

    // MARK: - MarkdownNode

    override class var rawType: cmark_node_type {
        CMARK_NODE_LINK
    }

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(node: self)
    }
}
