//
//  MarkdownVisitor.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.06.2023.
//

protocol MarkdownVisitor<Result> {

    associatedtype Result

    /// Vists document.
    func visit(node: MarkdownDocument) -> Result

    /// Vists paragraph node.
    func visit(node: MarkdownParagraph) -> Result

    /// Vists text node.
    func visit(node: MarkdownText) -> Result

    /// Vists list node.
    func visit(node: MarkdownList) -> Result

    /// Vists list item.
    func visit(node: MarkdownListItem) -> Result

    /// Vists strong node.
    func visit(node: MarkdownStrong) -> Result

    /// Vists emphasis node.
    func visit(node: MarkdownEmphasis) -> Result

    /// Vists unknown node.
    func visit(node: MarkdownUnknown) -> Result
}
