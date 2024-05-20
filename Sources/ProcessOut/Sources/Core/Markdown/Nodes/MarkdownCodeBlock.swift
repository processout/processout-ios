//
//  MarkdownCodeBlock.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 15.06.2023.
//

@_implementationOnly import cmark

final class MarkdownCodeBlock: MarkdownBaseNode {

    /// Returns the info string from a fenced code block.
    private(set) lazy var info: String? = {
        guard let info = cmarkNode.pointee.as.code.info else {
            return nil
        }
        return String(cString: info)
    }()

    private(set) lazy var code: String = {
        guard let literal = cmark_node_get_literal(cmarkNode) else {
            assertionFailure("Unable to get text node value")
            return ""
        }
        return String(cString: literal)
    }()

    // MARK: - MarkdownBaseNode

    override static var cmarkNodeType: cmark_node_type {
        CMARK_NODE_CODE_BLOCK
    }

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(codeBlock: self)
    }
}
