//
//  AttributedStringMarkdownVisitor.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.06.2023.
//

import Foundation
import UIKit

final class AttributedStringMarkdownVisitor: MarkdownVisitor {

    init(builder: AttributedStringBuilder, level: Int = 0) {
        self.builder = builder
        self.level = level
    }

    // MARK: - MarkdownVisitor

    func visit(node: MarkdownUnknown) -> NSAttributedString {
        node.children.map { $0.accept(visitor: self) }.joined()
    }

    func visit(document: MarkdownDocument) -> NSAttributedString {
        let separator = NSAttributedString(string: Constants.paragraphSeparator)
        return document.children.map { $0.accept(visitor: self) }.joined(separator: separator)
    }

    func visit(emphasis: MarkdownEmphasis) -> NSAttributedString {
        let visitor = AttributedStringMarkdownVisitor(builder: builder.with(symbolicTraits: .traitItalic), level: level)
        return emphasis.children.map { $0.accept(visitor: visitor) }.joined()
    }

    func visit(list: MarkdownList) -> NSAttributedString {
        let builder = builder.listLevel(level)
        let itemsSeparator = NSAttributedString(string: Constants.paragraphSeparator)
        let attributedString = list.children
            .enumerated()
            .map { offset, itemNode in
                let prefix = builder
                    .string(listItemPrefix(list: list, at: offset))
                    .build()
                let visitor = AttributedStringMarkdownVisitor(builder: builder, level: self.level + 1)
                let attributedString = itemNode.accept(visitor: visitor)
                return [prefix, attributedString].joined()
            }
            .joined(separator: itemsSeparator)
        return attributedString
    }

    func visit(listItem: MarkdownListItem) -> NSAttributedString {
        let separator = NSAttributedString(string: Constants.listItemsSeparator)
        return listItem.children.map { $0.accept(visitor: self) }.joined(separator: separator)
    }

    func visit(paragraph: MarkdownParagraph) -> NSAttributedString {
        paragraph.children.map { $0.accept(visitor: self) }.joined()
    }

    func visit(strong: MarkdownStrong) -> NSAttributedString {
        let visitor = AttributedStringMarkdownVisitor(builder: builder.with(symbolicTraits: .traitBold), level: level)
        return strong.children.map { $0.accept(visitor: visitor) }.joined()
    }

    func visit(text: MarkdownText) -> NSAttributedString {
        builder.string(text.value).build()
    }

    /// - NOTE: Softbreak is rendered with line break.
    func visit(softbreak: MarkdownSoftbreak) -> NSAttributedString {
        NSAttributedString(string: Constants.lineSeparator)
    }

    func visit(linebreak: MarkdownLinebreak) -> NSAttributedString {
        NSAttributedString(string: Constants.lineSeparator)
    }

    func visit(heading: MarkdownHeading) -> NSAttributedString {
        heading.children.map { $0.accept(visitor: self) }.joined()
    }

    func visit(blockQuote: MarkdownBlockQuote) -> NSAttributedString {
        let separator = NSAttributedString(string: Constants.paragraphSeparator)
        return blockQuote.children.map { $0.accept(visitor: self) }.joined(separator: separator)
    }

    func visit(codeBlock: MarkdownCodeBlock) -> NSAttributedString {
        let attributedString = builder
            .with(symbolicTraits: .traitMonoSpace)
            .string(codeBlock.code)
            .build()
        return attributedString
    }

    func visit(thematicBreak: MarkdownThematicBreak) -> NSAttributedString {
        NSAttributedString(string: Constants.lineSeparator)
    }

    func visit(codeSpan: MarkdownCodeSpan) -> NSAttributedString {
        let attributedString = builder
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
        static let lineSeparator = "\u{2028}"
        static let paragraphSeparator = "\u{2029}"
        static let listItemsSeparator = "\u{2029}\t\t"
        static let horizontalTab = "\t"
        static let bulletMarkers = ["•", "◦", "◆", "◇"]
        static let orderedListDelimiter = "."
    }

    // MARK: - Private Properties

    private let builder: AttributedStringBuilder
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
