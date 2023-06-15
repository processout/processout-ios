//
//  MarkdownText.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.06.2023.
//

@_implementationOnly import cmark

final class MarkdownText: MarkdownNode {

    private(set) lazy var value: String = {
        guard let literal = cmark_node_get_literal(cmarkNode) else {
            assertionFailure("Unable to get text node value")
            return ""
        }
        return String(cString: literal)
    }()

    // MARK: - MarkdownNode

    override class var cmarkNodeType: cmark_node_type {
        CMARK_NODE_TEXT
    }

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(node: self)
    }
}
