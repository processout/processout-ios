//
//  MarkdownDebugDescriptionPrinter.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.06.2023.
//

#if DEBUG

final class MarkdownDebugDescriptionPrinter: MarkdownVisitor {

    init(level: Int = 0) {
        self.level = level
    }

    // MARK: - MarkdownVisitor

    func visit(node: MarkdownUnknown) -> String {
        description(node: node, nodeName: "Unknown")
    }

    func visit(document: MarkdownDocument) -> String {
        description(node: document, nodeName: "Document")
    }

    func visit(emphasis: MarkdownEmphasis) -> String {
        description(node: emphasis, nodeName: "Emphasis")
    }

    func visit(list: MarkdownList) -> String {
        let attributes: [String: CustomStringConvertible]
        switch list.type {
        case let .ordered(delimiter, startIndex):
            attributes = ["start": startIndex, "delimiter": delimiter]
        case .bullet(let marker):
            attributes = ["marker": marker]
        }
        return description(node: list, nodeName: "List", attributes: attributes)
    }

    func visit(listItem: MarkdownListItem) -> String {
        description(node: listItem, nodeName: "Item")
    }

    func visit(paragraph: MarkdownParagraph) -> String {
        description(node: paragraph, nodeName: "Paragraph")
    }

    func visit(strong: MarkdownStrong) -> String {
        description(node: strong, nodeName: "Bold")
    }

    func visit(text: MarkdownText) -> String {
        description(node: text, nodeName: "Text", content: text.value)
    }

    func visit(softbreak: MarkdownSoftbreak) -> String {
        description(node: softbreak, nodeName: "Softbreak")
    }

    func visit(linebreak: MarkdownLinebreak) -> String {
        description(node: linebreak, nodeName: "Linebreak")
    }

    func visit(heading: MarkdownHeading) -> String {
        description(node: heading, nodeName: "Heading", attributes: ["level": heading.level])
    }

    func visit(blockQuote: MarkdownBlockQuote) -> String {
        description(node: blockQuote, nodeName: "Block Quote")
    }

    func visit(codeBlock: MarkdownCodeBlock) -> String {
        return description(node: codeBlock, nodeName: "Code Block", content: codeBlock.code)
    }

    func visit(thematicBreak: MarkdownThematicBreak) -> String {
        description(node: thematicBreak, nodeName: "Thematic Break")
    }

    func visit(codeSpan: MarkdownCodeSpan) -> String {
        description(node: codeSpan, nodeName: "Code Span", content: codeSpan.code)
    }

    func visit(link: MarkdownLink) -> String {
        var attributes: [String: CustomStringConvertible] = [:]
        if let url = link.url {
            attributes["url"] = url
        }
        return description(node: link, nodeName: "Link", attributes: attributes)
    }

    // MARK: - Private Properties

    private let level: Int

    // MARK: - Private Methods

    private func description(node: String, attributes: [String: CustomStringConvertible], content: String?) -> String {
        var description = String(repeating: " ", count: 2 * level) + "- " + node
        let attributesDescription = attributes
            .map { key, value in
                [key, value.description].joined(separator: "=")
            }
            .joined(separator: " ")
        if !attributesDescription.isEmpty {
            description += " (\(attributesDescription))"
        }
        if let content, !content.isEmpty {
            // Newlines and tabs are visualized for better readability.
            let escapedContent = content
                .replacingOccurrences(of: "\n", with: "\\n")
                .replacingOccurrences(of: "\t", with: "\\t")
            description += ": \(escapedContent)"
        }
        return description
    }

    private func description(
        node: MarkdownBaseNode,
        nodeName: String,
        attributes: [String: CustomStringConvertible] = [:],
        content: String? = nil
    ) -> String {
        var descriptionComponents = [
            description(node: nodeName, attributes: attributes, content: content)
        ]
        let childVisitor = MarkdownDebugDescriptionPrinter(level: level + 1)
        node.children.forEach { node in
            descriptionComponents.append(node.accept(visitor: childVisitor))
        }
        return descriptionComponents.joined(separator: "\n")
    }
}

extension MarkdownBaseNode: CustomDebugStringConvertible {

    var debugDescription: String {
        let visitor = MarkdownDebugDescriptionPrinter()
        return self.accept(visitor: visitor)
    }
}

#endif
