//
//  AttributedStringMarkdownVisitor.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.06.2023.
//

import Foundation
import UIKit

final class AttributedStringMarkdownVisitor: MarkdownVisitor {

    init(stringBuilder: AttributedStringBuilder, level: Int = 0) {
        self.stringBuilder = stringBuilder
        self.level = level
    }

    // MARK: - MarkdownVisitor

    func visit(node: MarkdownUnknown) -> NSAttributedString {
        node.children.map { $0.accept(visitor: self) }.joined()
    }

    func visit(node: MarkdownDocument) -> NSAttributedString {
        let separator = stringBuilder.copy().string(Constants.paragraphSeparator).build()
        return node.children.map { $0.accept(visitor: self) }.joined(separator: separator)
    }

    func visit(node: MarkdownEmphasis) -> NSAttributedString {
        // todo(andrii-vysotskyi): add default italic font face variation
        let builder = stringBuilder.copy().with(symbolicTraits: .traitItalic)
        let visitor = AttributedStringMarkdownVisitor(stringBuilder: builder, level: level)
        return node.children.map { $0.accept(visitor: visitor) }.joined()
    }

    func visit(node: MarkdownList) -> NSAttributedString {
        let builder = stringBuilder.copy().headIndent(matchingTabs: level + 1)
        let itemsSeparator = builder
            .string(Constants.paragraphSeparator)
            .build()
        let attributedString = node.children
            .enumerated()
            .map { offset, itemNode in
                let prefix = builder
                    .string(listItemPrefix(list: node, at: offset))
                    .build()
                let visitor = AttributedStringMarkdownVisitor(stringBuilder: builder, level: self.level + 1)
                let attributedString = itemNode.accept(visitor: visitor)
                return [prefix, attributedString].joined()
            }
            .joined(separator: itemsSeparator)
        return attributedString
    }

    func visit(node: MarkdownListItem) -> NSAttributedString {
        let separator = stringBuilder.copy().string(Constants.paragraphSeparator).build()
        return node.children.map { $0.accept(visitor: self) }.joined(separator: separator)
    }

    func visit(node: MarkdownParagraph) -> NSAttributedString {
        node.children.map { $0.accept(visitor: self) }.joined()
    }

    func visit(node: MarkdownStrong) -> NSAttributedString {
        let builder = stringBuilder.copy().with(symbolicTraits: .traitBold)
        let visitor = AttributedStringMarkdownVisitor(stringBuilder: builder, level: level)
        return node.children.map { $0.accept(visitor: visitor) }.joined()
    }

    func visit(node: MarkdownText) -> NSAttributedString {
        assert(node.children.isEmpty)
        return stringBuilder.copy().string(node.value).build()
    }

    /// - NOTE: Softbreak is rendered with line break.
    func visit(node: MarkdownSoftbreak) -> NSAttributedString {
        assert(node.children.isEmpty)
        return stringBuilder.copy().string(Constants.lineSeparator).build()
    }

    func visit(node: MarkdownLinebreak) -> NSAttributedString {
        assert(node.children.isEmpty)
        return stringBuilder.copy().string(Constants.lineSeparator).build()
    }

    func visit(node: MarkdownHeading) -> NSAttributedString {
        node.children.map { $0.accept(visitor: self) }.joined()
    }

    func visit(node: MarkdownBlockQuote) -> NSAttributedString {
        let separator = stringBuilder.copy().string(Constants.paragraphSeparator).build()
        return node.children.map { $0.accept(visitor: self) }.joined(separator: separator)
    }

    func visit(node: MarkdownCodeBlock) -> NSAttributedString {
        assert(node.children.isEmpty)
        let attributedString = stringBuilder
            .copy()
            .with(symbolicTraits: .traitMonoSpace)
            .string(node.code.replacingOccurrences(of: Constants.legacyLineSeparator, with: Constants.lineSeparator))
            .build()
        return attributedString
    }

    func visit(node: MarkdownThematicBreak) -> NSAttributedString {
        stringBuilder.copy().string(Constants.lineSeparator).build()
    }

    func visit(node: MarkdownCodeSpan) -> NSAttributedString {
        assert(node.children.isEmpty)
        let attributedString = stringBuilder
            .copy()
            .with(symbolicTraits: .traitMonoSpace)
            .string(node.code)
            .build()
        return attributedString
    }

    func visit(node: MarkdownLink) -> NSAttributedString {
        let attributedString = node.children
            .map { $0.accept(visitor: self) }
            .joined()
            .mutableCopy() as! NSMutableAttributedString // swiftlint:disable:this force_cast
        if let url = node.url {
            let range = NSRange(location: 0, length: attributedString.length)
            attributedString.addAttribute(.link, value: url, range: range)
        }
        return attributedString
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let space = " "
        static let legacyLineSeparator = "\u{2028}"
        static let lineSeparator = "\u{2028}"
        static let paragraphSeparator = "\u{2029}"
        static let horizontalTab = "\t"
        static let bulletMarkers = ["•", "◦", "◆", "◇"]
        static let orderedListDelimiter = "."
    }

    // MARK: - Private Properties

    private let stringBuilder: AttributedStringBuilder
    private let level: Int

    // MARK: - Private Methods

    private func listItemPrefix(list: MarkdownList, at index: Int) -> String {
        // Original markers/delimiters are ignored
        var components = Array(repeating: Constants.horizontalTab, count: level + 1)
        switch list.type {
        case .ordered(_, let startIndex):
            components += [
                (startIndex + index).description, Constants.orderedListDelimiter
            ]
        case .bullet:
            components.append(Constants.bulletMarkers[level % Constants.bulletMarkers.count])
        }
        components.append(Constants.space)
        return components.joined()
    }
}
