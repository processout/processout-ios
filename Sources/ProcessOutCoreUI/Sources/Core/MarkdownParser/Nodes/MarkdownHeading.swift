//
//  MarkdownHeading.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 15.06.2023.
//

import cmark_gfm

final class MarkdownHeading: MarkdownBaseNode {

    private(set) lazy var level: Int = {
        Int(cmarkNode.pointee.as.heading.level)
    }()

    // MARK: - MarkdownBaseNode

    override static var cmarkNodeType: cmark_node_type {
        CMARK_NODE_HEADING
    }

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(heading: self)
    }
}
