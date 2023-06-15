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
    func visit(node: MarkdownDocument) -> Result

    /// Vists emphasis node.
    func visit(node: MarkdownEmphasis) -> Result

    /// Vists list node.
    func visit(node: MarkdownList) -> Result

    /// Vists list item.
    func visit(node: MarkdownListItem) -> Result

    /// Vists paragraph node.
    func visit(node: MarkdownParagraph) -> Result

    /// Vists strong node.
    func visit(node: MarkdownStrong) -> Result

    /// Vists text node.
    func visit(node: MarkdownText) -> Result

    /// Vists softbreak node.
    func visit(node: MarkdownSoftbreak) -> Result

    /// Vists linebreak node.
    func visit(node: MarkdownLinebreak) -> Result

    /// Vists heading node.
    func visit(node: MarkdownHeading) -> Result

    /// Vists block quote.
    func visit(node: MarkdownBlockQuote) -> Result

    /// Vists code block
    func visit(node: MarkdownCodeBlock) -> Result

    /// Vists thematic break.
    func visit(node: MarkdownThematicBreak) -> Result

    /// Vists code span.
    func visit(node: MarkdownCodeSpan) -> Result

    /// Vists link node.
    func visit(node: MarkdownLink) -> Result
}
