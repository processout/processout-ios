//
//  MarkdownLink.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 15.06.2023.
//

struct MarkdownLink: MarkdownNode {

    let url: String?

    // MARK: - MarkdownNode

    let children: [MarkdownNode]

    func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(link: self)
    }
}
