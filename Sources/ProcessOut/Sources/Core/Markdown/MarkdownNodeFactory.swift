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
        // HTML and images are intentionally ignored.
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
        MarkdownEmphasis.rawType.rawValue: MarkdownEmphasis.init,
        MarkdownBlockQuote.rawType.rawValue: MarkdownBlockQuote.init,
        MarkdownCodeBlock.rawType.rawValue: MarkdownCodeBlock.init,
        MarkdownCodeSpan.rawType.rawValue: MarkdownCodeSpan.init,
        MarkdownHeading.rawType.rawValue: MarkdownHeading.init,
        MarkdownLinebreak.rawType.rawValue: MarkdownLinebreak.init,
        MarkdownSoftbreak.rawType.rawValue: MarkdownSoftbreak.init,
        MarkdownThematicBreak.rawType.rawValue: MarkdownThematicBreak.init,
        MarkdownLink.rawType.rawValue: MarkdownLink.init
    ]

    private let rawNode: MarkdownNode.NodePointer
}
