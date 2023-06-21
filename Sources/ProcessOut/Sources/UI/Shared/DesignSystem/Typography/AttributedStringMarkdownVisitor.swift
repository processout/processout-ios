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
        let itemsSeparator = NSAttributedString(string: Constants.paragraphSeparator)
        let attributedString = list.children
            .enumerated()
            .map { offset, itemNode in
                var builder = self.builder
                builder.textLists.append(textList(list, forItemAt: offset))
                let visitor = AttributedStringMarkdownVisitor(builder: builder, level: self.level + 1)
                return itemNode.accept(visitor: visitor)
            }
            .joined(separator: itemsSeparator)
        return attributedString
    }

    func visit(listItem: MarkdownListItem) -> NSAttributedString {
        let separator = NSAttributedString(string: Constants.paragraphSeparator)
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
        let code = codeBlock.code
            .replacingOccurrences(of: "\n", with: Constants.lineSeparator)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return builder.with(symbolicTraits: .traitMonoSpace).string(code).build()
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
    }

    // MARK: - Private Properties

    private let builder: AttributedStringBuilder
    private let level: Int

    // MARK: - Private Methods

    private func textList(_ list: MarkdownList, forItemAt index: Int) -> NSTextList {
        let textList: NSTextList
        switch list.type {
        case .ordered(_, let startIndex):
            let markerFormat = NSTextList.MarkerFormat("{decimal}.")
            textList = NSTextList(markerFormat: markerFormat, options: 0)
            textList.startingItemNumber = startIndex + index
        case .bullet:
            let markers: [NSTextList.MarkerFormat] = [.disc, .circle]
            textList = NSTextList(markerFormat: markers[level % markers.count], options: 0)
        }
        return textList
    }
}
