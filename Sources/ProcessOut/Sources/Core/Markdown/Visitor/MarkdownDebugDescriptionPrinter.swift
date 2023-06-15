//
//  MarkdownDebugDescriptionPrinter.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.06.2023.
//

import Foundation

final class MarkdownDebugDescriptionPrinter: MarkdownVisitor {

    init(level: Int = 0) {
        self.level = level
    }

    // MARK: - MarkdownVisitor

    func visit(node: MarkdownUnknown) -> String {
        description(node: node, nodeName: "Unknown")
    }

    func visit(node: MarkdownDocument) -> String {
        description(node: node, nodeName: "Document")
    }

    func visit(node: MarkdownEmphasis) -> String {
        description(node: node, nodeName: "Emphasis")
    }

    func visit(node: MarkdownList) -> String {
        let attributes: [String: CustomStringConvertible]
        switch node.type {
        case let .ordered(delimiter, startIndex):
            attributes = ["start": startIndex, "delimiter": delimiter]
        case .bullet(let marker):
            attributes = ["marker": marker]
        }
        return description(node: node, nodeName: "List", attributes: attributes)
    }

    func visit(node: MarkdownListItem) -> String {
        description(node: node, nodeName: "Item")
    }

    func visit(node: MarkdownParagraph) -> String {
        description(node: node, nodeName: "Paragraph")
    }

    func visit(node: MarkdownStrong) -> String {
        description(node: node, nodeName: "Bold")
    }

    func visit(node: MarkdownText) -> String {
        description(node: node, nodeName: "Text", content: node.value)
    }

    func visit(node: MarkdownSoftbreak) -> String {
        description(node: node, nodeName: "Softbreak")
    }

    func visit(node: MarkdownLinebreak) -> String {
        description(node: node, nodeName: "Linebreak")
    }

    func visit(node: MarkdownHeading) -> String {
        description(node: node, nodeName: "Heading", attributes: ["level": node.level])
    }

    func visit(node: MarkdownBlockQuote) -> String {
        description(node: node, nodeName: "Block Quote")
    }

    func visit(node: MarkdownCodeBlock) -> String {
        var attributes: [String: CustomStringConvertible] = [:]
        if let info = node.info {
            attributes["info"] = info
        }
        return description(node: node, nodeName: "Code Block", attributes: attributes, content: node.code)
    }

    func visit(node: MarkdownThematicBreak) -> String {
        description(node: node, nodeName: "Thematic Break")
    }

    func visit(node: MarkdownCodeSpan) -> String {
        description(node: node, nodeName: "Code Span", content: node.code)
    }

    func visit(node: MarkdownLink) -> String {
        var attributes: [String: CustomStringConvertible] = [:]
        if let title = node.title {
            attributes["title"] = title
        }
        return description(node: node, nodeName: "Link", attributes: attributes, content: node.url)
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
        node: MarkdownNode,
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

extension MarkdownNode: CustomDebugStringConvertible {

    var debugDescription: String {
        let visitor = MarkdownDebugDescriptionPrinter()
        return self.accept(visitor: visitor)
    }
}
