//
//  MarkdownVisitor.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.06.2023.
//

protocol MarkdownVisitor<Result> {

    associatedtype Result

    /// Vists unknown node.
    func visit(node: MarkdownUnknown) -> Result

    /// Vists document.
    func visit(document: MarkdownDocument) -> Result

    /// Vists emphasis node.
    func visit(emphasis: MarkdownEmphasis) -> Result

    /// Vists list node.
    func visit(list: MarkdownList) -> Result

    /// Vists list item.
    func visit(listItem: MarkdownListItem) -> Result

    /// Vists paragraph node.
    func visit(paragraph: MarkdownParagraph) -> Result

    /// Vists strong node.
    func visit(strong: MarkdownStrong) -> Result

    /// Vists text node.
    func visit(text: MarkdownText) -> Result

    /// Vists softbreak node.
    func visit(softbreak: MarkdownSoftbreak) -> Result

    /// Vists linebreak node.
    func visit(linebreak: MarkdownLinebreak) -> Result

    /// Vists heading node.
    func visit(heading: MarkdownHeading) -> Result

    /// Vists block quote.
    func visit(blockQuote: MarkdownBlockQuote) -> Result

    /// Vists code block
    func visit(codeBlock: MarkdownCodeBlock) -> Result

    /// Vists thematic break.
    func visit(thematicBreak: MarkdownThematicBreak) -> Result

    /// Vists code span.
    func visit(codeSpan: MarkdownCodeSpan) -> Result

    /// Vists link node.
    func visit(link: MarkdownLink) -> Result
}
