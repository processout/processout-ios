//
//  MarkdownDocument.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 11.06.2023.
//

struct MarkdownDocument: MarkdownNode {

    let children: [MarkdownNode]

    func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(document: self)
    }
}
