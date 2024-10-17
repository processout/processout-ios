//
//  MarkdownParagraph.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 12.06.2023.
//

struct MarkdownParagraph: MarkdownNode {

    let children: [MarkdownNode]

    func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(paragraph: self)
    }
}
