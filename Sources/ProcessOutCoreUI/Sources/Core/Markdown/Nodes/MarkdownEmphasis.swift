//
//  MarkdownEmphasis.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 12.06.2023.
//

struct MarkdownEmphasis: MarkdownNode {

    let children: [MarkdownNode]

    func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(emphasis: self)
    }
}
