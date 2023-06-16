//
//  MarkdownUnknown.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 15.06.2023.
//

/// Unknown node.
final class MarkdownUnknown: MarkdownBaseNode {

    init(cmarkNode: MarkdownBaseNode.CmarkNode) {
        super.init(cmarkNode: cmarkNode, validatesType: false)
    }

    // MARK: - MarkdownBaseNode

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(node: self)
    }
}
