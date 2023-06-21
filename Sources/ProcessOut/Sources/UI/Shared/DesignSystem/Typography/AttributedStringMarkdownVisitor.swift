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

    func visit(document: MarkdownDocument) -> NSAttributedString {
        let separator = stringBuilder.string(Constants.paragraphSeparator).build()
        return document.children.map { $0.accept(visitor: self) }.joined(separator: separator)
    }

    func visit(emphasis: MarkdownEmphasis) -> NSAttributedString {
        let builder = stringBuilder.with(symbolicTraits: .traitItalic)
        let visitor = AttributedStringMarkdownVisitor(stringBuilder: builder, level: level)
        return emphasis.children.map { $0.accept(visitor: visitor) }.joined()
    }

    func visit(list: MarkdownList) -> NSAttributedString {
        let builder = stringBuilder.listLevel(level)
        let itemsSeparator = builder
            .string(Constants.paragraphSeparator)
            .build()
        let attributedString = list.children
            .enumerated()
            .map { offset, itemNode in
                let prefix = builder
                    .string(listItemPrefix(list: list, at: offset))
                    .build()
                let visitor = AttributedStringMarkdownVisitor(stringBuilder: builder, level: self.level + 1)
                let attributedString = itemNode.accept(visitor: visitor)
                return [prefix, attributedString].joined()
            }
            .joined(separator: itemsSeparator)
        return attributedString
    }

    func visit(listItem: MarkdownListItem) -> NSAttributedString {
        let separator = stringBuilder.string(Constants.listItemsSeparator).build()
        return listItem.children.map { $0.accept(visitor: self) }.joined(separator: separator)
    }

    func visit(paragraph: MarkdownParagraph) -> NSAttributedString {
        paragraph.children.map { $0.accept(visitor: self) }.joined()
    }

    func visit(strong: MarkdownStrong) -> NSAttributedString {
        let builder = stringBuilder.with(symbolicTraits: .traitBold)
        let visitor = AttributedStringMarkdownVisitor(stringBuilder: builder, level: level)
        return strong.children.map { $0.accept(visitor: visitor) }.joined()
    }

    func visit(text: MarkdownText) -> NSAttributedString {
        assert(text.children.isEmpty)
        return stringBuilder.string(text.value).build()
    }

    /// - NOTE: Softbreak is rendered with line break.
    func visit(softbreak: MarkdownSoftbreak) -> NSAttributedString {
        assert(softbreak.children.isEmpty)
        return stringBuilder.string(Constants.lineSeparator).build()
    }

    func visit(linebreak: MarkdownLinebreak) -> NSAttributedString {
        assert(linebreak.children.isEmpty)
        return stringBuilder.string(Constants.lineSeparator).build()
    }

    func visit(heading: MarkdownHeading) -> NSAttributedString {
        heading.children.map { $0.accept(visitor: self) }.joined()
    }

    func visit(blockQuote: MarkdownBlockQuote) -> NSAttributedString {
        let separator = stringBuilder.string(Constants.paragraphSeparator).build()
        return blockQuote.children.map { $0.accept(visitor: self) }.joined(separator: separator)
    }

    func visit(codeBlock: MarkdownCodeBlock) -> NSAttributedString {
        assert(codeBlock.children.isEmpty)
        let attributedString = stringBuilder
            .with(symbolicTraits: .traitMonoSpace)
            .string(
                codeBlock.code.replacingOccurrences(of: Constants.legacyLineSeparator, with: Constants.lineSeparator)
            )
            .build()
        return attributedString
    }

    func visit(thematicBreak: MarkdownThematicBreak) -> NSAttributedString {
        stringBuilder.string(Constants.lineSeparator).build()
    }

    func visit(codeSpan: MarkdownCodeSpan) -> NSAttributedString {
        assert(codeSpan.children.isEmpty)
        let attributedString = stringBuilder
            .with(symbolicTraits: .traitMonoSpace)
            .string(codeSpan.code)
            .build()
        return attributedString
    }

    func visit(link: MarkdownLink) -> NSAttributedString {
        let attributedString = link.children
            .map { $0.accept(visitor: self) }
            .joined()
            .mutableCopy() as! NSMutableAttributedString // swiftlint:disable:this force_cast
        if let url = link.url {
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
        static let listItemsSeparator = "\u{2029}\t\t"
        static let horizontalTab = "\t"
        static let bulletMarkers = ["•", "◦", "◆", "◇"]
        static let orderedListDelimiter = "."
    }

    // MARK: - Private Properties

    private let stringBuilder: AttributedStringBuilder
    private let level: Int

    // MARK: - Private Methods

    private func listItemPrefix(list: MarkdownList, at index: Int) -> String {
        var components = [Constants.horizontalTab]
        // Original markers/delimiters are ignored
        switch list.type {
        case .ordered(_, let startIndex):
            components += [
                (startIndex + index).description, Constants.orderedListDelimiter
            ]
        case .bullet:
            components.append(Constants.bulletMarkers[level % Constants.bulletMarkers.count])
        }
        components.append(Constants.horizontalTab)
        return components.joined()
    }
}
