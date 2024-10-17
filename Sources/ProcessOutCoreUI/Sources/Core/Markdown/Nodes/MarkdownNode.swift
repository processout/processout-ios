//
//  MarkdownNode.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 13.06.2023.
//

protocol MarkdownNode: Sendable {

    /// Returns node children.
    var children: [MarkdownNode] { get }

    /// Accepts given visitor.
    func accept<V: MarkdownVisitor>(visitor: V) -> V.Result
}
