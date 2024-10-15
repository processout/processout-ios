//
//  MarkdownVisitor.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 12.06.2023.
//

protocol MarkdownVisitor<Result> {

    associatedtype Result

    /// Visits document.
    func visit(document: MarkdownDocument) -> Result

    /// Visits emphasis node.
    func visit(emphasis: MarkdownEmphasis) -> Result

    /// Visits list node.
    func visit(list: MarkdownList) -> Result

    /// Visits list item.
    func visit(listItem: MarkdownListItem) -> Result

    /// Visits paragraph node.
    func visit(paragraph: MarkdownParagraph) -> Result

    /// Visits strong node.
    func visit(strong: MarkdownStrong) -> Result

    /// Visits text node.
    func visit(text: MarkdownText) -> Result

    /// Visits softbreak node.
    func visit(softbreak: MarkdownSoftbreak) -> Result

    /// Visits linebreak node.
    func visit(linebreak: MarkdownLinebreak) -> Result

    /// Visits heading node.
    func visit(heading: MarkdownHeading) -> Result

    /// Visits block quote.
    func visit(blockQuote: MarkdownBlockQuote) -> Result

    /// Visits code block
    func visit(codeBlock: MarkdownCodeBlock) -> Result

    /// Visits thematic break.
    func visit(thematicBreak: MarkdownThematicBreak) -> Result

    /// Visits code span.
    func visit(codeSpan: MarkdownCodeSpan) -> Result

    /// Visits link node.
    func visit(link: MarkdownLink) -> Result
}
