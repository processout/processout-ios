//
//  MarkdownHeading.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 15.06.2023.
//

@_implementationOnly import cmark

final class MarkdownHeading: MarkdownNode {

    private(set) lazy var level: Int = {
        Int(cmarkNode.pointee.as.heading.level)
    }()

    // MARK: - MarkdownNode

    override class var cmarkNodeType: cmark_node_type {
        CMARK_NODE_HEADING
    }

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(node: self)
    }
}
