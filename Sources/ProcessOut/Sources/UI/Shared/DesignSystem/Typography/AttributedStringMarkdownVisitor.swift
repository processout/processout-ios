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
        var builder = builder
        builder.symbolicTraits.formUnion(.traitItalic)
        let visitor = AttributedStringMarkdownVisitor(builder: builder, level: level)
        return emphasis.children.map { $0.accept(visitor: visitor) }.joined()
    }

    func visit(list: MarkdownList) -> NSAttributedString {
        var builder = self.builder
        let textList = textList(list)
        builder.textLists.append(textList)
        if #unavailable(iOS 16) {
            builder.tabStops += listTabStops(textList, itemsCount: list.children.count)
            if let tabStop = builder.tabStops.last {
                builder.headIndent += tabStop.location
            }
        }
        let itemsSeparator = NSAttributedString(string: Constants.paragraphSeparator)
        let attributedString = list.children
            .enumerated()
            .map { offset, itemNode in
                let childVisitor = AttributedStringMarkdownVisitor(builder: builder, level: self.level + 1)
                let attributedItem = itemNode.accept(visitor: childVisitor)
                guard #unavailable(iOS 16) else {
                    return attributedItem
                }
                let marker =
                    String(repeating: Constants.tab, count: level * 2 + 1) +
                    textList.marker(forItemNumber: textList.startingItemNumber + offset) +
                    Constants.tab
                let attributedMarker = builder.string(marker).build()
                return [attributedMarker, attributedItem].joined()
            }
            .joined(separator: itemsSeparator)
        return attributedString
    }

    func visit(listItem: MarkdownListItem) -> NSAttributedString {
        // todo(andrii-vysotskyi): add tabulation when joining children on iOS < 16
        let separator = NSAttributedString(string: Constants.paragraphSeparator)
        return listItem.children.map { $0.accept(visitor: self) }.joined(separator: separator)
    }

    func visit(paragraph: MarkdownParagraph) -> NSAttributedString {
        paragraph.children.map { $0.accept(visitor: self) }.joined()
    }

    func visit(strong: MarkdownStrong) -> NSAttributedString {
        var builder = builder
        builder.symbolicTraits.formUnion(.traitBold)
        let visitor = AttributedStringMarkdownVisitor(builder: builder, level: level)
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
            .trimmingCharacters(in: .newlines)
        var builder = builder
        builder.symbolicTraits.formUnion(.traitMonoSpace)
        return builder.string(code).build()
    }

    func visit(thematicBreak: MarkdownThematicBreak) -> NSAttributedString {
        NSAttributedString(string: Constants.lineSeparator)
    }

    func visit(codeSpan: MarkdownCodeSpan) -> NSAttributedString {
        var builder = builder
        builder.symbolicTraits.formUnion(.traitMonoSpace)
        return builder.string(codeSpan.code).build()
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
        static let listMarkerWidthMultiplier: CGFloat = 2
        static let listMarkerSpacing: CGFloat = 4
        static let lineSeparator = "\u{2028}"
        static let paragraphSeparator = "\u{2029}"
        static let tab = "\t"
    }

    // MARK: - Private Properties

    private let builder: AttributedStringBuilder
    private let level: Int

    // MARK: - Private Methods

    private func textList(_ list: MarkdownList) -> NSTextList {
        let textList: NSTextList
        switch list.type {
        case .ordered(_, let startIndex):
            let markerFormat = NSTextList.MarkerFormat("{decimal}.")
            textList = NSTextList(markerFormat: markerFormat, options: 0)
            textList.startingItemNumber = startIndex
        case .bullet:
            let markers: [NSTextList.MarkerFormat] = [.disc, .circle]
            textList = NSTextList(markerFormat: markers[level % markers.count], options: 0)
        }
        return textList
    }

    @available(iOS, obsoleted: 16.0)
    private func listTabStops(_ textList: NSTextList, itemsCount: Int) -> [NSTextTab] {
        guard itemsCount > 0 else {
            return []
        }
        // Last item is expected to have longest marker.
        let marker = textList.marker(forItemNumber: textList.startingItemNumber + itemsCount - 1)
        let indentation = builder.string(marker).build().size().width * Constants.listMarkerWidthMultiplier
        let parentIndentation = builder.tabStops.last?.location ?? 0
        let tabStops = [
            NSTextTab(textAlignment: .right, location: parentIndentation + indentation),
            NSTextTab(textAlignment: .left, location: parentIndentation + indentation + Constants.listMarkerSpacing)
        ]
        return tabStops
    }
}
