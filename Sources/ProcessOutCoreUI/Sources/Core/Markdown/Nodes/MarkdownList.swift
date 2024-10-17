//
//  MarkdownList.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 12.06.2023.
//

struct MarkdownList: MarkdownNode {

    enum Kind {

        /// Ordered
        case ordered(delimiter: Character, startIndex: Int)

        /// Bullet aka unordered list.
        case bullet(marker: Character)
    }

    /// List type.
    let type: Kind

    /// Indicates whether list is tight.
    let isTight: Bool

    // MARK: - MarkdownNode

    let children: [MarkdownNode]

    func accept<V: MarkdownVisitor>(visitor: V) -> V.Result {
        visitor.visit(list: self)
    }
}
