//
//  MarkdownNodeFactory.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.06.2023.
//

@_implementationOnly import cmark

final class MarkdownNodeFactory {

    init(rawNode: MarkdownNode.CmarkNode) {
        self.rawNode = rawNode
    }

    func create() -> MarkdownNode {
        let nodeType = UInt32(rawNode.pointee.type)
        guard nodeType != CMARK_NODE_NONE.rawValue else {
            preconditionFailure("Invalid node")
        }
        // HTML and images are intentionally not supported.
        guard let nodeInit = Self.nodeInits[nodeType] else {
            assertionFailure("Unknown node type: \(nodeType)")
            return MarkdownUnknown(cmarkNode: rawNode)
        }
        return nodeInit(rawNode, true)
    }

    // MARK: - Private Properties

    private static let nodeInits = [
        MarkdownDocument.cmarkNodeType.rawValue: MarkdownDocument.init,
        MarkdownText.cmarkNodeType.rawValue: MarkdownText.init,
        MarkdownParagraph.cmarkNodeType.rawValue: MarkdownParagraph.init,
        MarkdownList.cmarkNodeType.rawValue: MarkdownList.init,
        MarkdownListItem.cmarkNodeType.rawValue: MarkdownListItem.init,
        MarkdownStrong.cmarkNodeType.rawValue: MarkdownStrong.init,
        MarkdownEmphasis.cmarkNodeType.rawValue: MarkdownEmphasis.init,
        MarkdownBlockQuote.cmarkNodeType.rawValue: MarkdownBlockQuote.init,
        MarkdownCodeBlock.cmarkNodeType.rawValue: MarkdownCodeBlock.init,
        MarkdownCodeSpan.cmarkNodeType.rawValue: MarkdownCodeSpan.init,
        MarkdownHeading.cmarkNodeType.rawValue: MarkdownHeading.init,
        MarkdownLinebreak.cmarkNodeType.rawValue: MarkdownLinebreak.init,
        MarkdownSoftbreak.cmarkNodeType.rawValue: MarkdownSoftbreak.init,
        MarkdownThematicBreak.cmarkNodeType.rawValue: MarkdownThematicBreak.init,
        MarkdownLink.cmarkNodeType.rawValue: MarkdownLink.init
    ]

    private let rawNode: MarkdownNode.CmarkNode
}
