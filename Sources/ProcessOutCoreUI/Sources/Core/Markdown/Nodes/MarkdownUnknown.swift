//
//  MarkdownUnknown.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 15.06.2023.
//

/// Unknown node.
final class MarkdownUnknown: MarkdownBaseNode {

    required init(cmarkNode: CmarkNode, validatesType: Bool = false) {
        super.init(cmarkNode: cmarkNode, validatesType: false)
    }

    // MARK: - MarkdownBaseNode

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(node: self)
    }
}
