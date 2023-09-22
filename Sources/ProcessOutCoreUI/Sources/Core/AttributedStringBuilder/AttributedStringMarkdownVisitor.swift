//
//  AttributedStringMarkdownVisitor.swift
//  ProcessOutCoreUI
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
        builder.fontSymbolicTraits.formUnion(.traitItalic)
        let visitor = AttributedStringMarkdownVisitor(builder: builder, level: level)
        return emphasis.children.map { $0.accept(visitor: visitor) }.joined()
    }

    func visit(list: MarkdownList) -> NSAttributedString {
        var builder = self.builder
        let textList = textList(list)
        builder.tabStops += listTabStops(textList, itemsCount: list.children.count)
        if let tabStop = builder.tabStops.last {
            builder.headIndent = tabStop.location
        }
        let itemsSeparator = NSAttributedString(string: Constants.paragraphSeparator)
        let attributedString = list.children
            .enumerated()
            .map { offset, itemNode in
                let childVisitor = AttributedStringMarkdownVisitor(builder: builder, level: self.level + 1)
                let attributedItem = itemNode.accept(visitor: childVisitor)
                let marker =
                    String(repeating: Constants.tab, count: level * 2 + 1) +
                    textList.marker(forItemNumber: textList.startingItemNumber + offset) +
                    Constants.tab
                let attributedMarker = builder.with { $0.text = .plain(marker) }.build()
                return [attributedMarker, attributedItem].joined()
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
        var builder = builder
        builder.fontSymbolicTraits.formUnion(.traitBold)
        let visitor = AttributedStringMarkdownVisitor(builder: builder, level: level)
        return strong.children.map { $0.accept(visitor: visitor) }.joined()
    }

    func visit(text: MarkdownText) -> NSAttributedString {
        builder.with { $0.text = .plain(text.value) }.build()
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
        builder.fontSymbolicTraits.formUnion(.traitMonoSpace)
        return builder.with { $0.text = .plain(code) }.build()
    }

    func visit(thematicBreak: MarkdownThematicBreak) -> NSAttributedString {
        NSAttributedString(string: Constants.lineSeparator)
    }

    func visit(codeSpan: MarkdownCodeSpan) -> NSAttributedString {
        var builder = builder
        builder.fontSymbolicTraits.formUnion(.traitMonoSpace)
        return builder.with { $0.text = .plain(codeSpan.code) }.build()
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
        static let listMarkerWidthIncrement: CGFloat = 12
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

    private func listTabStops(_ textList: NSTextList, itemsCount: Int) -> [NSTextTab] {
        guard itemsCount > 0 else {
            return []
        }
        // Last item is expected to have the longest marker, but just to be safe,
        // we are additionally increasing calculated width.
        let marker = textList.marker(forItemNumber: textList.startingItemNumber + itemsCount - 1)
        let indentation = builder
            .with { $0.text = .plain(marker) }
            .build()
            .size()
            .width + Constants.listMarkerWidthIncrement
        let parentIndentation = builder.tabStops.last?.location ?? 0
        let tabStops = [
            NSTextTab(textAlignment: .right, location: parentIndentation + indentation),
            NSTextTab(textAlignment: .left, location: parentIndentation + indentation + Constants.listMarkerSpacing)
        ]
        return tabStops
    }
}
