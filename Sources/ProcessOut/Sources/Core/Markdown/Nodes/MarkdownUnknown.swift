//
//  MarkdownUnknown.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 15.06.2023.
//

import Foundation

/// Unknown node.
final class MarkdownUnknown: MarkdownNode {

    init(cmarkNode: MarkdownNode.CmarkNode) {
        super.init(cmarkNode: cmarkNode, validatesType: false)
    }

    // MARK: - MarkdownNode

    override func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(node: self)
    }
}
