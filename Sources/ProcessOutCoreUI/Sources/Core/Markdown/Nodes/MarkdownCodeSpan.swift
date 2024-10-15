//
//  MarkdownCodeSpan.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 15.06.2023.
//

struct MarkdownCodeSpan: MarkdownNode {

    /// Code.
    let code: String

    // MARK: - MarkdownNode

    let children: [MarkdownNode]

    func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(codeSpan: self)
    }
}
