//
//  MarkdownParser.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 13.06.2023.
//

import cmark_gfm

final class MarkdownParser {

    func parse(string: String) -> MarkdownNode {
        let pDocumentNode = string.withCString { pointer in
            cmark_parse_document(pointer, strlen(pointer), CMARK_OPT_SMART)
        }
        guard let pDocumentNode else {
            return MarkdownDocument(children: [])
        }
        defer {
            cmark_node_free(pDocumentNode)
        }
        guard let documentNode = node(from: pDocumentNode) else {
            return MarkdownDocument(children: [])
        }
        return documentNode
    }

    // MARK: - Utils

    private func children(of pNode: UnsafeMutablePointer<cmark_node>) -> [MarkdownNode] {
        var pChildNode = pNode.pointee.first_child
        var children: [MarkdownNode] = []
        while let ptrChildNode = pChildNode {
            if let markdownNode = node(from: ptrChildNode) {
                children.append(markdownNode)
            }
            pChildNode = ptrChildNode.pointee.next
        }
        return children
    }

    // MARK: - Bridging

    // swiftlint:disable:next cyclomatic_complexity
    private func node(from pNode: UnsafeMutablePointer<cmark_node>) -> MarkdownNode? {
        let nodeType = cmark_node_type(
            UInt32(pNode.pointee.type)
        )
        // HTML and images are intentionally not supported.
        switch nodeType {
        case CMARK_NODE_DOCUMENT:
            return documentNode(from: pNode)
        case CMARK_NODE_BLOCK_QUOTE:
            return blockQuoteNode(from: pNode)
        case CMARK_NODE_CODE_BLOCK:
            return codeBlockNode(from: pNode)
        case CMARK_NODE_CODE:
            return codeSpanNode(from: pNode)
        case CMARK_NODE_EMPH:
            return emphasisNode(from: pNode)
        case CMARK_NODE_HEADING:
            return headingNode(from: pNode)
        case CMARK_NODE_LINEBREAK:
            return linebreakNode(from: pNode)
        case CMARK_NODE_LINK:
            return linkNode(from: pNode)
        case CMARK_NODE_LIST:
            return listNode(from: pNode)
        case CMARK_NODE_ITEM:
            return listItemNode(from: pNode)
        case CMARK_NODE_PARAGRAPH:
            return paragraphNode(from: pNode)
        case CMARK_NODE_SOFTBREAK:
            return softbreakNode(from: pNode)
        case CMARK_NODE_STRONG:
            return strongNode(from: pNode)
        case CMARK_NODE_TEXT:
            return textNode(from: pNode)
        case CMARK_NODE_THEMATIC_BREAK:
            return thematicBreakNode(from: pNode)
        default:
            return nil
        }
    }

    // MARK: - Nodes Bridging

    private func documentNode(from pNode: UnsafeMutablePointer<cmark_node>) -> MarkdownNode {
        MarkdownDocument(children: children(of: pNode))
    }

    private func blockQuoteNode(from pNode: UnsafeMutablePointer<cmark_node>) -> MarkdownNode {
        MarkdownBlockQuote(children: children(of: pNode))
    }

    private func codeBlockNode(from pNode: UnsafeMutablePointer<cmark_node>) -> MarkdownNode? {
        guard let literal = cmark_node_get_literal(pNode) else {
            return nil
        }
        let code = String(cString: literal)
        return MarkdownCodeBlock(code: code, children: children(of: pNode))
    }

    private func codeSpanNode(from pNode: UnsafeMutablePointer<cmark_node>) -> MarkdownNode? {
        guard let literal = cmark_node_get_literal(pNode) else {
            return nil
        }
        let code = String(cString: literal)
        return MarkdownCodeSpan(code: code, children: children(of: pNode))
    }

    private func emphasisNode(from pNode: UnsafeMutablePointer<cmark_node>) -> MarkdownNode {
        MarkdownEmphasis(children: children(of: pNode))
    }

    private func headingNode(from pNode: UnsafeMutablePointer<cmark_node>) -> MarkdownNode {
        let level = Int(pNode.pointee.as.heading.level)
        return MarkdownHeading(level: level, children: children(of: pNode))
    }

    private func linebreakNode(from pNode: UnsafeMutablePointer<cmark_node>) -> MarkdownNode {
        MarkdownLinebreak(children: children(of: pNode))
    }

    private func linkNode(from pNode: UnsafeMutablePointer<cmark_node>) -> MarkdownNode {
        let url = String(cString: pNode.pointee.as.link.url.data)
        return MarkdownLink(url: url, children: children(of: pNode))
    }

    private func listNode(from pNode: UnsafeMutablePointer<cmark_node>) -> MarkdownNode? {
        let type: MarkdownList.Kind, listNode = pNode.pointee.as.list
        switch listNode.list_type {
        case CMARK_BULLET_LIST:
            let marker = Character(Unicode.Scalar(listNode.bullet_char))
            type = .bullet(marker: marker)
        case CMARK_ORDERED_LIST:
            let delimiter: Character
            switch cmark_node_get_list_delim(pNode) {
            case CMARK_PERIOD_DELIM:
                delimiter = "."
            case CMARK_PAREN_DELIM:
                delimiter = ")"
            default:
                return nil
            }
            let startIndex = Int(listNode.start)
            type = .ordered(delimiter: delimiter, startIndex: startIndex)
        default:
            return nil
        }
        let isTight = pNode.pointee.as.list.tight
        return MarkdownList(type: type, isTight: isTight, children: children(of: pNode))
    }

    private func listItemNode(from pNode: UnsafeMutablePointer<cmark_node>) -> MarkdownNode {
        MarkdownListItem(children: children(of: pNode))
    }

    private func paragraphNode(from pNode: UnsafeMutablePointer<cmark_node>) -> MarkdownNode {
        MarkdownParagraph(children: children(of: pNode))
    }

    private func softbreakNode(from pNode: UnsafeMutablePointer<cmark_node>) -> MarkdownNode {
        MarkdownSoftbreak(children: children(of: pNode))
    }

    private func strongNode(from pNode: UnsafeMutablePointer<cmark_node>) -> MarkdownNode {
        MarkdownStrong(children: children(of: pNode))
    }

    private func textNode(from pNode: UnsafeMutablePointer<cmark_node>) -> MarkdownNode? {
        guard let literal = cmark_node_get_literal(pNode) else {
            return nil
        }
        let value = String(cString: literal)
        return MarkdownText(value: value, children: children(of: pNode))
    }

    private func thematicBreakNode(from pNode: UnsafeMutablePointer<cmark_node>) -> MarkdownNode {
        MarkdownThematicBreak(children: children(of: pNode))
    }
}
