//
//  MarkdownCodeBlock.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 15.06.2023.
//

@_implementationOnly import cmark

final class MarkdownCodeBlock: MarkdownBaseNode, @unchecked Sendable {

    /// Actual code value.
    let code: String

    // MARK: - MarkdownBaseNode

    required init(cmarkNode: MarkdownBaseNode.CmarkNode, validatesType: Bool = true) {
        if let literal = cmark_node_get_literal(cmarkNode) {
            self.code = String(cString: literal)
        } else {
            self.code = ""
        }
        super.init(cmarkNode: cmarkNode, validatesType: validatesType)
    }

    override static var cmarkNodeType: cmark_node_type {
        CMARK_NODE_CODE_BLOCK
    }

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(codeBlock: self)
    }
}
