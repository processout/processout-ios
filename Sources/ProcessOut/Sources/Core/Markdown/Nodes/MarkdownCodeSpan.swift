//
//  MarkdownCodeSpan.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 15.06.2023.
//

@_implementationOnly import cmark

final class MarkdownCodeSpan: MarkdownBaseNode, @unchecked Sendable {

    /// Code.
    let code: String

    // MARK: - MarkdownBaseNode

    required init(cmarkNode: MarkdownBaseNode.CmarkNode, validatesType: Bool = true) {
        if let literal = cmark_node_get_literal(cmarkNode) {
            code = String(cString: literal)
        } else {
            assertionFailure("Unable to get text node value")
            code = ""
        }
        super.init(cmarkNode: cmarkNode, validatesType: validatesType)
    }

    override static var cmarkNodeType: cmark_node_type {
        CMARK_NODE_CODE
    }

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(codeSpan: self)
    }
}
