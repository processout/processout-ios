//
//  MarkdownText.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.06.2023.
//

@_implementationOnly import cmark

final class MarkdownText: MarkdownBaseNode {

    private(set) lazy var value: String = {
        guard let literal = cmark_node_get_literal(cmarkNode) else {
            assertionFailure("Unable to get text node value")
            return ""
        }
        return String(cString: literal)
    }()

    // MARK: - MarkdownBaseNode

    override class var cmarkNodeType: cmark_node_type {
        CMARK_NODE_TEXT
    }

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(text: self)
    }
}
