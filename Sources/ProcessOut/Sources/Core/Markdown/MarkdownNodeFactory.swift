//
//  MarkdownNodeFactory.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.06.2023.
//

import cmark_gfm

final class MarkdownNodeFactory {

    init(cmarkNode: MarkdownBaseNode.CmarkNode) {
        self.cmarkNode = cmarkNode
    }

    func create() -> MarkdownBaseNode {
        let nodeType = UInt32(cmarkNode.pointee.type)
        guard nodeType != CMARK_NODE_NONE.rawValue else {
            preconditionFailure("Invalid node")
        }
        // HTML and images are intentionally not supported.
        guard let nodeClass = Self.supportedNodes[nodeType] else {
            return MarkdownUnknown(cmarkNode: cmarkNode)
        }
        return nodeClass.init(cmarkNode: cmarkNode)
    }

    // MARK: - Private Properties

    private static let supportedNodes: [UInt32: MarkdownBaseNode.Type] = {
        let supportedNodes = [
            MarkdownDocument.self,
            MarkdownText.self,
            MarkdownParagraph.self,
            MarkdownList.self,
            MarkdownListItem.self,
            MarkdownStrong.self,
            MarkdownEmphasis.self,
            MarkdownBlockQuote.self,
            MarkdownCodeBlock.self,
            MarkdownCodeSpan.self,
            MarkdownHeading.self,
            MarkdownLinebreak.self,
            MarkdownSoftbreak.self,
            MarkdownThematicBreak.self,
            MarkdownLink.self
        ]
        return Dictionary(grouping: supportedNodes) { $0.cmarkNodeType.rawValue }.compactMapValues(\.first)
    }()

    private let cmarkNode: MarkdownBaseNode.CmarkNode
}
