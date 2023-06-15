//
//  MarkdownNodeFactory.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.06.2023.
//

@_implementationOnly import cmark

final class MarkdownNodeFactory {

    init(rawNode: MarkdownNode.NodePointer) {
        self.rawNode = rawNode
    }

    func create() -> MarkdownNode {
        let nodeType = UInt32(rawNode.pointee.type)
        guard nodeType != CMARK_NODE_NONE.rawValue else {
            preconditionFailure("Invalid node")
        }
        guard let nodeInit = Self.nodeInits[nodeType] else {
            assertionFailure("Unknown node type: \(nodeType)")
            return MarkdownUnknown(node: rawNode)
        }
        return nodeInit(rawNode, true)
    }

    // MARK: - Private Properties

    private static let nodeInits = [
        MarkdownDocument.rawType.rawValue: MarkdownDocument.init,
        MarkdownText.rawType.rawValue: MarkdownText.init,
        MarkdownParagraph.rawType.rawValue: MarkdownParagraph.init,
        MarkdownList.rawType.rawValue: MarkdownList.init,
        MarkdownListItem.rawType.rawValue: MarkdownListItem.init,
        MarkdownStrong.rawType.rawValue: MarkdownStrong.init,
        MarkdownEmphasis.rawType.rawValue: MarkdownEmphasis.init
    ]

    private let rawNode: MarkdownNode.NodePointer
}
