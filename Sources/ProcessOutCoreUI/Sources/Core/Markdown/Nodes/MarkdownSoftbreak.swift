//
//  MarkdownSoftbreak.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 15.06.2023.
//

struct MarkdownSoftbreak: MarkdownNode {

    let children: [MarkdownNode]

    func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(softbreak: self)
    }
}
